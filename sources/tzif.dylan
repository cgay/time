Module: %time
Synopsis: Read TZif (RFC 8536) file format

// Note that this code uses the big-integer and generic-arithmetic libraries with a
// module prefix in order to be able to accept the full range of 64-bit integers in the
// TZif data. By design, once the data has been processed only integers that will fit in
// Dylan's 62-bit signed integers (days and nanos) remain, so the main time code doesn't
// need to take a performance hit and code that uses time doesn't need to handle extended
// integers.

// --- Errors ---

define class <tzif-error> (<time-error>) end;

define class <not-tzif-format-error> (<tzif-error>) end;

define function tzif-error (format-string, #rest format-arguments)
  signal(make(<tzif-error>,
              format-string: format-string,
              format-arguments: format-arguments));
end function;

// --- Debugging ---

// zdump can be useful for debugging TZif:
// ./tzdb/zdump -V /usr/share/zoneinfo/Hongkong

define variable *debug-tzif?* = #f;

define function debug-tzif (fmt, #rest args)
  if (*debug-tzif?*)
    apply(format-err, fmt, args);
    force-err();
  end;
end function;

ignorable(debug-tzif);

// --- TZif ---

// <tzif> encapsulates one TZif format record, which is a description of one time
// zone. These are only used during parsing. The result of parsing a TZif record is an
// <aware-zone>.
define class <tzif> (<object>)
  // The zone long name. On Linux this is from the basename of the file containing the
  // data.
  constant slot tzif-zone-name :: <string>, required-init-keyword: name:;
  constant slot tzif-data :: <byte-vector>, required-init-keyword: data:;
  // A way to identify the data source for error messages and debugging. Often a full
  // pathname, but that should not be assumed.
  constant slot tzif-source :: <string>, required-init-keyword: source:;
  slot tzif-version;             // 1, 2, or 3
  slot tzif-end-of-v1-data;      // = v2 data start
  slot tzif-end-of-v2-data = -1; // = footer start, -1 if only v1 present
  slot tzif-is-utc-count;
  slot tzif-is-std-count;
  slot tzif-leap-count;
  slot tzif-time-count;
  slot tzif-type-count;
  slot tzif-char-count;
end class;

define method print-object (t :: <tzif>, stream :: <stream>) => ()
  printing-object (t, stream)
    format(stream, "%s v=%d v1-end=%d v2-end=%d is-utc=%d is-std=%d leap=%d time=%d type=%d char=%d",
           t.tzif-source,
           t.tzif-version,
           t.tzif-end-of-v1-data,
           t.tzif-end-of-v2-data,
           t.tzif-is-utc-count,
           t.tzif-is-std-count,
           t.tzif-leap-count,
           t.tzif-time-count,
           t.tzif-type-count,
           t.tzif-char-count);
  end;
end method;

// Load all TZif format files in `root-directory`. Return a map from zone names to <zone>
// objects. This is designed to read the /usr/share/zoneinfo directory on Linux.
define function load-tzif-zones
    (root-directory :: <directory-locator>) => (zones :: <string-table>)
  let zones = make(<string-table>, size: 700);
  let loaded-files = make(<string-table>, size: 700);
  local
    method add-zone (name :: <string>, zone :: <zone>, locator :: <file-locator>)
                 => (z :: <zone>?)
      debug-tzif("loaded zone %s (%s) from %s\n", zone, name, locator);
      let name2 = map(method (c) iff(c = '_', ' ', c) end, name);
      if (name ~= name2)
        zones[name2] := zone;
      end;
      zones[name] := zone
    end,
    method load-file (directory, filename) => (z :: <zone>?)
      let locator = merge-locators(as(<file-locator>, filename),
                                   as(<directory-locator>, directory));
      // Name is taken from the original filename without first following links.
      let name = as(<string>, simplify-locator(relative-locator(locator, root-directory)));
      // File has links fully resolved.
      let file = as(<string>, resolve-locator(locator));
      let zone-by-name = element(zones, name, default: #f);
      let zone-by-file = element(loaded-files, file, default: #f);
      case
        zone-by-name =>
          zone-by-name;
        zone-by-file =>
          // Loading a link to a file that was already loaded; just map the new name.
          add-zone(name, zone-by-file, locator);
        otherwise =>
          let zone = block ()
                       load-tzif-file(name, locator)
                     exception (<not-tzif-format-error>)
                       #f
                     end;
          if (zone)
            loaded-files[file] := zone;
            add-zone(name, zone, locator)
          end;
      end case
    end method,
    method do-one (directory, filename, type)
      select (type)
        #"file", #"link" =>
          load-file(directory, filename);
        #"directory" =>
          do-directory(do-one, subdirectory-locator(as(<directory-locator>, directory),
                                                    filename));
      end select;
    end method;
  do-directory(do-one, root-directory);
  debug-tzif("Loaded %d zones\n", zones.size);
  zones
end function;

define constant $tzif-header-octet-count = 44;

// Load a TZif format file. Signal an error if it isn't TZif format or claims
// to be but is malformatted.
define function load-tzif-file
    (name :: <string>, file :: <file-locator>) => (zone :: <zone>?)
  with-open-file (stream = file, direction: #"input", element-type: <byte>)
    let data = read-to-end(stream);
    let tzif = make(<tzif>,
                    name: name,
                    data: data,
                    source: as(<string>, file));
    load-zone(tzif)
  end
end function;

define function load-zone (tzif :: <tzif>) => (zone :: <aware-zone>)
  decode-header(tzif, 0, 1);
  // Version 1 block is always present, but should be ignored if the version is 2 or
  // higher.
  select (tzif.tzif-version)
    1 =>
      decode-tzif-data-block(tzif, $tzif-header-octet-count, 4);
    2, 3 =>
      decode-header(tzif, tzif.tzif-end-of-v1-data, tzif.tzif-version);
      decode-tzif-data-block(tzif, tzif.tzif-end-of-v1-data + $tzif-header-octet-count, 8);
  end
end function;

// Parse the headers starting at `start` and store the values into `tzif`.
define function decode-header
    (tzif :: <tzif>, start :: <integer>, version :: <integer>)
  let data :: <byte-vector> = tzif.tzif-data;
  if (~tzif?(data, start))
    error(make(<not-tzif-format-error>,
               format-string: "%s: magic 'TZif' bytes not found at position %d",
               format-arguments: list(tzif.tzif-source, start)));
  end;
  tzif.tzif-version := select (data[start + 4])
                         0 => 1;
                         as(<integer>, '2') => 2;
                         as(<integer>, '3') => 3;
                         otherwise =>
                           tzif-error("%s: unrecognized TZif version: %=",
                                      tzif.tzif-source, data[start + 4]);
                       end;
  // Version 1 data counts must be parsed even in version 2+ so that we can
  // skip v1 data. The primary difference between v1 and v2+ is the move from
  // 32-bit to 64-bit times.
  tzif.tzif-is-utc-count := bytes-to-int32(data, start + 20, "isutccnt");
  tzif.tzif-is-std-count := bytes-to-int32(data, start + 24, "isstdcnt");
  tzif.tzif-leap-count := bytes-to-int32(data, start + 28, "leapcnt");
  tzif.tzif-time-count := bytes-to-int32(data, start + 32, "timecnt");
  tzif.tzif-type-count := bytes-to-int32(data, start + 36, "typecnt");
  tzif.tzif-char-count := bytes-to-int32(data, start + 40, "charcnt");
  let time-size = iff(version = 1, 4, 8);
  let data-end
    = start + $tzif-header-octet-count
            + tzif.tzif-time-count * time-size       // transition times
            + tzif.tzif-time-count                   // transition types
            + tzif.tzif-type-count * 6               // local time type records
            + tzif.tzif-char-count                   // time zone designations
            + tzif.tzif-leap-count * (time-size + 4) // leap-second records
            + tzif.tzif-is-std-count                 // standard/wall indicators
            + tzif.tzif-is-utc-count;                // UT/local indicators
  if (version = 1)
    tzif.tzif-end-of-v1-data := data-end;
  else
    tzif.tzif-end-of-v2-data := data-end;
  end;
  debug-tzif("v=%d, isutcnt=%d, isstdcnt=%d, leapcnt=%d, timecnt=%d, typecnt=%d, charcnt=%d\n",
             version, tzif.tzif-is-utc-count, tzif.tzif-is-std-count, tzif.tzif-leap-count,
             tzif.tzif-time-count, tzif.tzif-type-count, tzif.tzif-char-count);
end function;

// Parse the data block beginning at `start` with times that are `time-size` bytes
// long. `time-size` is either 4 or 8.
define function decode-tzif-data-block
    (tzif :: <tzif>, start :: <integer>, time-size :: <integer>) => (zone :: <zone>)
  let source = tzif.tzif-source;
  let data = tzif.tzif-data;
  let trans-time-start = start;
  let trans-type-start = trans-time-start + (time-size * tzif.tzif-time-count);
  let local-time-start = trans-type-start + tzif.tzif-time-count;
  let tz-designator-start = local-time-start + (6 * tzif.tzif-type-count);
  let leap-second-start   = tz-designator-start + tzif.tzif-char-count;
  let std/wall-start = leap-second-start + ((4 + 4) * tzif.tzif-leap-count);
  let ut/local-start = std/wall-start + tzif.tzif-is-std-count;
  debug-tzif("trans-times=%d, trans-types=%d, local-times=%d, tz-strings=%d,"
               " leap-seconds=%d, std/wall=%d, ut/local=%d\n",
             trans-time-start, trans-type-start, local-time-start, tz-designator-start,
             leap-second-start, std/wall-start, ut/local-start);
  let (local-offsets, local-dsts, local-abbrevs)
    = decode-local-time-types(tzif, local-time-start, tz-designator-start,
                              leap-second-start);

  // TODO: read the leap second records.

  let subzones = make(<stretchy-vector>);

  // Times before the first subzone are determined by the first local time type record.
  // It is valid for a TZif file to specify no transition times, or to never use the
  // first local time type record in a transition time so we unconditionally add a
  // subzone here as the oldest subzone.
  add!(subzones, make(<subzone>,
                      start-time: $minimum-time,
                      offset-seconds: local-offsets[0],
                      abbrev: local-abbrevs[0],
                      dst?: local-dsts[0]));

  // Make a subzone starting at each transition time record.
  for (i from 0 below tzif.tzif-time-count)
    let bytes-to-int = select (time-size)
                         4 => bytes-to-int32;
                         8 => bytes-to-int64;
                       end;
    let transition-time = bytes-to-int(data, trans-time-start + (i * time-size), "transtime");
    let local-time-type-index = data[trans-type-start + i];
    let utc-offset-seconds = local-offsets[local-time-type-index];
    // We get a potentially extended integer back from bytes-to-int64 but here,
    // after flooring, it should be a native Dylan integer, which we guarantee
    // by specifying the types of the receivng variables.
    let (days :: <integer>, seconds :: <integer>) = ga/floor/(transition-time, 86400);
    let time = make(<time>, days: days, nanoseconds: abs(seconds) * 1_000_000_000);
    let subzone = make(<subzone>,
                       start-time: time,
                       offset-seconds: local-offsets[local-time-type-index],
                       abbrev: local-abbrevs[local-time-type-index],
                       dst?: local-dsts[local-time-type-index]);
    add!(subzones, subzone);
  end for;
  decode-footer(subzones, data, tzif.tzif-end-of-v2-data, data.size);
  make(<aware-zone>,
       name: tzif.tzif-zone-name,
       subzones: reverse!(subzones))
end function;

define function decode-local-time-types
    (tzif :: <tzif>, start-of-data :: <integer>, tz-abbrev-start :: <integer>,
     leap-second-start :: <integer>)
  let count = tzif.tzif-type-count;
  let local-offsets = make(<vector>, size: count);
  let local-dsts = make(<vector>, size: count);
  let local-abbrevs = make(<vector>, size: count);
  let data = tzif.tzif-data;
  for (i from 0 below tzif.tzif-type-count,
       start from start-of-data by 6)
    local-offsets[i] := bytes-to-int32(data, start, "utcoff");
    local-dsts[i]
      := select (data[start + 4])
           0 => #f;
           1 => #t;
           otherwise
             => tzif-error("%s: invalid is-dst value %d should be 0 or 1,"
                             " for local time type starting at index %d",
                           tzif.tzif-source, data[start + 4], start);
         end;
    let tz-index = data[start + 5];
    local-abbrevs[i]
      := parse-nul-terminated-string(data, tz-abbrev-start + tz-index, leap-second-start);
    debug-tzif("local offset=%d, dst=%=, tz-index=%d, abbrev=%s\n",
               local-offsets[i], local-dsts[i], tz-index, local-abbrevs[i]);
  end;
  values(local-offsets, local-dsts, local-abbrevs)
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

define function bytes-to-int64 (bytes, start, id) => (i :: ga/<integer>)
  // Conveniently, RFC 8536 says the most negative time SHOULD be -2^59, so we
  // can hope for no overflow due to tag bits here. No mention of most positive
  // time value so let's just hope no one needs a time more than 14 billion
  // years in the future.
  let high-order-byte :: <byte> = bytes[start];
  if (logbit?(7, high-order-byte))
    // Negative number. Parse the complement as unsigned and then negate it.
    ga/-(0, ga/+(ga/logior(ga/ash(logxor(255, high-order-byte), 56),
                           ash(logxor(255, bytes[start + 1]), 48),
                           ash(logxor(255, bytes[start + 2]), 40),
                           ash(logxor(255, bytes[start + 3]), 32),
                           ash(logxor(255, bytes[start + 4]), 24),
                           ash(logxor(255, bytes[start + 5]), 16),
                           ash(logxor(255, bytes[start + 6]), 8),
                           logxor(255, bytes[start + 7])),
                 1))
  else
    ga/logior(ga/ash(high-order-byte, 56),
              ash(bytes[start + 1], 48),
              ash(bytes[start + 2], 40),
              ash(bytes[start + 3], 32),
              ash(bytes[start + 4], 24),
              ash(bytes[start + 5], 16),
              ash(bytes[start + 6], 8),
              bytes[start + 7])
  end
end function;

// Parse a NUL-terminated string from `bytes`. A NUL byte must come before `epos`.
define not-inline function parse-nul-terminated-string
    (bytes, bpos, epos) => (_ :: <string>?, pos :: <integer>)
  let v = make(<stretchy-vector>);
  iterate loop (i = bpos)
    if (i >= epos)
      values(#f, i)
    elseif (bytes[i] = 0)
      values(map-as(<string>, curry(as, <character>), v),
             i)
    else
      add!(v, bytes[i]);
      loop(i + 1)
    end
  end
end function;

// Parse the version 2 and 3 footer, which gives a rule for computing local time changes
// after the last transition time. The rule is specified here:
// https://pubs.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap08.html
define function decode-footer (subzones, bytes, bpos, epos) => ()
  // TODO: parse the footer. Looks somewhat involved so I'll put it off until more basic
  // features that allow replacing the current date library are done. Probably not going
  // to be able to just add subzones since times can be billions of years in the future.
end function;
