Module: %time
Synopsis: Read TZif (RFC 8536) file format

define class <tzif-error> (<simple-error>) end;

define function tzif-error (format-string, #rest format-arguments)
  signal(make(<tzif-error>,
              format-string: format-string,
              format-arguments: format-arguments));
end function;

// <tzif> encapsulates one TZif format file. The file basename is the time zone name.
// These are only used during parsing. The result of parsing a TZif file is an
// <aware-zone>.
define class <tzif> (<object>)
  constant slot tzif-file :: <string>, init-keyword: file:;
  constant slot tzif-data :: <byte-vector>, init-keyword: data:;
  slot tzif-version;
  slot tzif-end-of-v1-data;
  slot tzif-is-ut-count;
  slot tzif-is-std-count;
  slot tzif-leap-count;
  slot tzif-time-count;
  slot tzif-type-count;
  slot tzif-char-count;
end class;

define method print-object (t :: <tzif>, stream :: <stream>) => ()
  printing-object (t, stream)
    format(stream, "v=%d v1-end=%d is-ut=%d is-std=%d leap=%d time=%d type=%d char=%d",
           t.tzif-version,
           t.tzif-end-of-v1-data,
           t.tzif-is-ut-count,
           t.tzif-is-std-count,
           t.tzif-leap-count,
           t.tzif-time-count,
           t.tzif-type-count,
           t.tzif-char-count);
  end;
end method;

define function load-tzif-zone-data
    (root-directory :: <directory-locator>) => (zones :: <sequence>)
  let zones = make(<stretchy-vector>);
  local
    method load-one (directory, filename, type)
      if (type = #"file" | type = #"link")
        let zone
          = load-tzif-file(make(<file-locator>, directory: root-directory, name: filename));
        if (zone)
          // TODO: ensure that we don't have two zones with the same name
          add!(zones, zone)
        end;
      end;
    end method;
  do-directory(load-one, root-directory);
  zones
end function;

define constant $tzif-header-octet-count = 44;

// Load a TZif format file. Signal an error if it isn't TZif format or claims
// to be but is malformatted. If debug? is true, print debug info on stderr.
define function load-tzif-file
    (file :: <file-locator>) => (zone :: <zone>?)
  with-open-file (stream = file, element-type: <byte>)
    debug-out("tzif: reading TZif file %s\n", file);
    let data = read-to-end(stream);
    debug-out("tzif data: %=\n", data);
    let tzif = make(<tzif>, file: as(<string>, file), data: data);
    parse-header(tzif, 0, 4);
    debug-out("tzif: %=\n", tzif);
    // Version 1 block is always present.
    parse-v1-zone(tzif, $tzif-header-octet-count);
    /* TODO: v2+
    select (tzif.tzif-version)
      1 => #f;                  // already parsed
      2, 3 =>
        parse-header(tzif, tzif.tzif-end-of-v1-data, 8);
        parse-v2-zone(tzif, tzif.tzif-end-of-v1-data + $tzif-header-octet-count);
    end
    */
  end
end function;

// Parse the headers starting at `start` and store the values into `tzif`.
define function parse-header
    (tzif :: <tzif>, start :: <integer>, time-size :: <integer>)
  let data :: <byte-vector> = tzif.tzif-data;
  if (~tzif?(data, start))
    tzif-error("%s: magic 'TZif' bytes not found at position %d",
               tzif.tzif-file, start);
  end;
  tzif.tzif-version := select (data[start + 4])
                         0 => 1;
                         as(<integer>, '2') => 2;
                         as(<integer>, '3') => 3;
                         otherwise =>
                           tzif-error("%s: unrecognized TZif version: %=",
                                      tzif.tzif-file, data[start + 4]);
                       end;
  // Version 1 data counts must be parsed even in version 2+ so that we can
  // skip v1 data. The primary difference between v1 and v2+ is the move from
  // 32-bit to 64-bit integers.
  tzif.tzif-is-ut-count := bytes-to-int32(data, start + 20, "is-ut count");
  tzif.tzif-is-std-count := bytes-to-int32(data, start + 20 + time-size, "is-std count");
  tzif.tzif-leap-count := bytes-to-int32(data, start + 20 + time-size * 2, "leap count");
  tzif.tzif-time-count := bytes-to-int32(data, start + 20 + time-size * 3, "time count");
  tzif.tzif-type-count := bytes-to-int32(data, start + 20 + time-size * 4, "type count");
  tzif.tzif-char-count := bytes-to-int32(data, start + 20 + time-size * 5, "char count");
  tzif.tzif-end-of-v1-data
    := (start + $tzif-header-octet-count
          + tzif.tzif-time-count * time-size       // transition times
          + tzif.tzif-time-count                   // transition types
          + tzif.tzif-type-count * 6               // local time type records
          + tzif.tzif-char-count                   // time zone designations
          + tzif.tzif-leap-count * (time-size + 4) // leap-second records
          + tzif.tzif-is-std-count                 // standard/wall indicators
          + tzif.tzif-is-ut-count);                // UT/local indicators
end function;

define function parse-v1-zone
    (tzif :: <tzif>, start :: <integer>) => (zone :: <zone>)
  let data = tzif.tzif-data;
  let time-size = 4;
  let trans-time-start = $tzif-header-octet-count;
  let trans-type-start = trans-time-start + (time-size * tzif.tzif-time-count);
  let local-time-start = trans-type-start + tzif.tzif-time-count;
  let tz-designator-start = local-time-start + (6 * tzif.tzif-type-count);
  let leap-second-start   = tz-designator-start + tzif.tzif-char-count;
  let std/wall-start = leap-second-start + ((4 + 4) * tzif.tzif-leap-count);
  let ut/local-start = std/wall-start + tzif.tzif-is-std-count;

  debug-out("\ntimes=%d types=%d locals=%d tzs=%d leaps=%d std=%d ut/loc=%d\n",
            trans-time-start, trans-type-start, local-time-start,
            tz-designator-start, leap-second-start, std/wall-start,
            ut/local-start);

  // Read the null-terminated, possibly empty, time zone designator strings.
  let tz-abbrevs = make(<table>);
  let bpos = tz-designator-start;
  while (bpos < leap-second-start)
    let (abbrev, epos) = parse-string(data, bpos, leap-second-start);
    if (abbrev)
      // The keys in tz-abbrevs are the indexes relative to tz-designator-start.
      let key = bpos - tz-designator-start;
      debug-out("tz-abbrevs[%d] := %s\n", key, abbrev);
      tz-abbrevs[key] := abbrev;
      bpos := epos + 1;
    else
      tzif-error("%s: ran out of data parsing TZ abbrev names", tzif.tzif-file)
    end;
  end;

  local method parse-local-time-types ()
          let count = tzif.tzif-type-count;
          let local-offsets = make(<vector>, size: count);
          let local-dsts = make(<vector>, size: count);
          let local-abbrevs = make(<vector>, size: count);
          for (i from 0 below count,
               start from local-time-start by 6)
            local-offsets[i] := bytes-to-int32(data, start, "utc-offset");
            local-dsts[i]
              := select (data[start + time-size])
                   0 => #f;
                   1 => #t;
                   otherwise => tzif-error("%s: invalid is-dst value %d should be 0 or 1,"
                                             " for local time type starting at index %d",
                                           data[start + time-size], start);
                 end;
            let tz-index = data[start + 5];
            debug-out("tz-index=%d, dst=%d\n", tz-index, data[start + time-size]);
            local-abbrevs[i] := tz-abbrevs[tz-index];
          end;
          values(local-offsets, local-dsts, local-abbrevs)
        end method;
  let (local-offsets, local-dsts, local-abbrevs) = parse-local-time-types();

  // TODO: read the leap second records.

  // Read the time records
  let subzones = make(<stretchy-vector>);
  for (i from 0 below tzif.tzif-time-count)
    // is this seconds?
    let transition-time = bytes-to-int32(data, trans-time-start + (i * time-size), "transition time");
    let local-time-type-index = data[trans-type-start + i];
    let utc-offset-seconds = local-offsets[local-time-type-index];
    let (days, seconds) = floor/(transition-time, 86400);
    let time = make(<time>, days: days, nanoseconds: abs(seconds) * 1_000_000_000);
    let subzone = make(<subzone>,
                       start-time: time,
                       offset-seconds: local-offsets[local-time-type-index],
                       abbrev: local-abbrevs[local-time-type-index],
                       dst?: local-dsts[local-time-type-index]);
    //debug-out("time = %s and %=\n", time, time);
    debug-out("subzone = %=\n", subzone);
    add!(subzones, subzone);
  end for;
  make(<aware-zone>,
       // TODO: this is not right. It will result in names like HongKong and New_York.
       // Not sure yet how the TZ names are determined but it looks like it's based on
       // the pathnames in /usr/share/zoneinfo, such as .../America/New_York, where we'll
       // have to use some hueristics like replacing _ with space.
       name: locator-base(as(<file-locator>, tzif.tzif-file)),
       subzones: reverse!(subzones))
end function;

define function parse-v2-zone
    (tzif :: <tzif>, start :: <integer>) => (zone :: <zone>)
  tzif-error("version 2 and 3 zone data not implemented");
end function;

define function tzif? (data :: <byte-vector>, start :: <integer>)
  block (return)
    for (char in "TZif", i from start)
      if (i >= data.size | as(<integer>, char) ~= data[i])
        return(#f);
      end;
    end;
    #t
  end
end function;

// Read a 4-byte network order twos-complement int32 from `data` starting at `start`.
// TODO: won't work on 32-bit arch, need big-integers library.
// id is temporary, for debugging
define function bytes-to-int32 (bytes, start, id) => (i :: <integer>)
  let high-order-byte :: <byte> = bytes[start];
  let v = if (logbit?(7, high-order-byte))
            // Negative number. Parse the complement as unsigned and then negate it.
            -(logior(ash(logxor(255, high-order-byte), 24),
                     ash(logxor(255, bytes[start + 1]), 16),
                     ash(logxor(255, bytes[start + 2]), 8),
                     logxor(255, bytes[start + 3]))
                + 1)
          else
            logior(ash(high-order-byte, 24),
                   ash(bytes[start + 1], 16),
                   ash(bytes[start + 2], 8),
                   bytes[start + 3])
          end;
//  debug-out("\nstart=%d, %d %d %d %d => %d (%s)\n",
//            start, bytes[start], bytes[start + 1], bytes[start + 2], bytes[start + 3], v, id);
  v
end function;

define function bytes-to-int64 (bytes, #key start = 0) => (i :: <integer>)
  // Conveniently, RFC 8536 says the most negative time SHOULD be -2^59, so we
  // can hope for no overflow due to tag bits here. No mention of most positive
  // time value so let's just hope no one needs a time more than 14 billion
  // years in the future.
  let high-order-byte :: <byte> = bytes[start];
  if (logbit?(7, high-order-byte))
    // Negative number. Parse the complement as unsigned and then negate it.
    -(logior(ash(logxor(255, high-order-byte), 56),
             ash(logxor(255, bytes[start + 1]), 48),
             ash(logxor(255, bytes[start + 2]), 40),
             ash(logxor(255, bytes[start + 3]), 32),
             ash(logxor(255, bytes[start + 4]), 24),
             ash(logxor(255, bytes[start + 5]), 16),
             ash(logxor(255, bytes[start + 6]), 8),
             logxor(255, bytes[start + 7]))
        + 1)
  else
    logior(ash(bytes[start], 56),
           ash(bytes[start + 1], 48),
           ash(bytes[start + 2], 40),
           ash(bytes[start + 3], 32),
           ash(bytes[start + 4], 24),
           ash(bytes[start + 5], 16),
           ash(bytes[start + 6], 8),
           bytes[start + 7])
  end
end function;

// Parse a nul-terminated string from `bytes`.
define not-inline function parse-string (bytes, bpos, epos) => (_ :: <string>?, pos :: <integer>)
  let v = make(<stretchy-vector>);
  iterate loop (i = bpos)
    let byte = bytes[i];
    if (i >= epos)
      values(#f, i)
    elseif (byte = 0)
      values(map-as(<string>, curry(as, <character>), v),
             i)
    else
      add!(v, byte);
      loop(i + 1)
    end
  end
end function;
