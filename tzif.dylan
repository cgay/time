Module: %time
Synopsis: Read TZif (RFC 8536) file format

define class <tzif-error> (<simple-error>) end;

define function tzif-error (format-string, #rest format-arguments)
  signal(make(<tzif-error>,
              format-string: format-string,
              format-arguments: format-arguments));
end function;

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

define constant $tzif-header-octets = 44;

// Load a TZif format file. Signal an error if it isn't TZif format or claims
// to be but is malformatted. If debug? is true, print debug info on stderr.
define function load-tzif-file
    (file :: <file-locator>, #key debug?) => (zone :: <zone>?)
  with-open-file (stream = file, element-type: <byte>)
    debug? & format-err("tzif: reading TZif file %s\n", file);
    let data = read-to-end(stream);
    debug? & format-err("tzif data: %=\n", data);
    let tzif = make(<tzif>, file: as(<string>, file), data: data);
    parse-header(tzif, 0, 4);
    debug? & format-err("tzif: %=\n", tzif);
    debug? & force-err();
    parse-v1-zone(tzif, $tzif-header-octets);
    select (tzif.tzif-version)
      1 => parse-v1-zone(tzif, $tzif-header-octets);
      2, 3 =>
        parse-header(tzif, tzif.tzif-end-of-v1-data, 8);
        parse-v2-zone(tzif, tzif.tzif-end-of-v1-data + $tzif-header-octets);
    end
  end
end function;

// Parse the headers starting at start and store the values into `tzif`.
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
                           tzif-error("unrecognized TZif version: %=", data[start + 4]);
                       end;
  // Version 1 data counts must be parsed even in version 2+ so that we can
  // skip v1 data. The primary difference between v1 and v2+ is the move from
  // 32-bit to 64-bit integers.
  tzif.tzif-is-ut-count := bytes-to-int32(data, start: start + 20);
  tzif.tzif-is-std-count := bytes-to-int32(data, start: start + 20 + time-size);
  tzif.tzif-leap-count := bytes-to-int32(data, start: start + 20 + time-size * 2);
  tzif.tzif-time-count := bytes-to-int32(data, start: start + 20 + time-size * 3);
  tzif.tzif-type-count := bytes-to-int32(data, start: start + 20 + time-size * 4);
  tzif.tzif-char-count := bytes-to-int32(data, start: start + 20 + time-size * 5);
  tzif.tzif-end-of-v1-data
    := (start + $tzif-header-octets
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
  let trans-time-index = $tzif-header-octets;
  let trans-type-index = trans-time-index + (4 * tzif.tzif-time-count);
  let local-time-index = trans-type-index + tzif.tzif-time-count;
  let tz-designator-index = local-time-index + (6 * tzif.tzif-type-count);
  let leap-second-index   = tz-designator-index + tzif.tzif-char-count;
  let std/wall-index = leap-second-index + ((4 + 4) * tzif.tzif-leap-count);
  let ut/local-index = std/wall-index + tzif.tzif-is-std-count;

  let bytes = tzif.tzif-data;
  let subzones = make(<stretchy-vector>);
  while (trans-time-index < bytes.size)
    format-err("%d %d %d %d %d %d %d\n",
               trans-time-index, trans-type-index, local-time-index,
               tz-designator-index, leap-second-index, std/wall-index,
               ut/local-index);
    let ut = bytes-to-int32(bytes, start: trans-time-index);
    format-err("ut = %d\n", ut);
    let (days, seconds) = truncate/(ut, 86400);
    let time = make(<time>, days: days, nanoseconds: abs(seconds) * 1_000_000_000);
    format-err("time = %s and %=\n", time, time);
    let offset1 = bytes-to-int32(bytes, start: local-time-index);
    let dst = bytes[local-time-index + 4];
    if (dst ~= 0 & dst ~= 1)
      tzif-error("dst indicator in local time type record (%=) must be 0 or 1", dst);
    end;
    let idx = bytes[local-time-index + 5];
    let abbrev = bytes-to-string(bytes, start: tz-designator-index + idx);
    let subzone = make(<subzone>,
                       start-time: time,
                       offset: offset1,
                       abbrev: abbrev,
                       dst?: dst = 1);
    format-err("subzone = %=\n", subzone);
    force-err();
    add!(subzones, subzone);

    inc!(trans-time-index, 4);
    inc!(trans-type-index);
    inc!(local-time-index, 6);
    inc!(tz-designator-index);
    inc!(leap-second-index, 8);
    inc!(std/wall-index);
    inc!(ut/local-index);
  end while;
  make(<aware-zone>,
       name: "TODO",
       subzones: subzones)
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
define function bytes-to-int32 (bytes, #key start = 0) => (i :: <integer>)
  let high-order-byte :: <byte> = bytes[start];
  if (logbit?(7, high-order-byte))
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
  end
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
define function bytes-to-string (bytes, #key start = 0) => (_ :: <string>)
  let v = make(<stretchy-vector>);
  iterate loop (i = start)
    let byte = bytes[i];
    if (byte = 0)
      map-as(<string>, curry(as, <character>), v)
    else
      add!(v, byte);
      loop(i + 1)
    end
  end
end function;
