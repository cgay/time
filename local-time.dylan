Module: local-time

define class <timestamp> (<object>)
  slot day-of :: <integer> = 0, init-keyword: day:;
  slot sec-of :: <integer> = 0, init-keyword: sec:;
  slot nsec-of :: limited(<integer>, min: 0, max: 999999999) = 0, init-keyword: nsec:;
end class;

define class <subzone> (<object>)
  slot subzone-abbrev = #f, init-keyword: subzone-abbrev:;
  slot subzone-offset = #f, init-keyword: subzone-offset:;
  slot subzone-daylight-p = #f, init-keyword: subzone-daylight-p:;
end class;

define class <timezone> (<object>)
  slot timezone-transitions :: <simple-vector> = #[0],
       init-keyword: timezone-transitions:;
  slot timezone-indexes :: <simple-vector> = #[0], init-keyword: timezone-indexes:;
  slot timezone-subzones :: <simple-vector> = #[], init-keyword: timezone-subzones:;
  slot timezone-leap-seconds :: <list> = #f, init-keyword: timezone-leap-seconds:;
  slot timezone-path = #f, init-keyword: timezone-path:;
  slot timezone-name :: <string> = "anonymous", init-keyword: timezone-name:;
  slot timezone-loaded :: <boolean> = #f, init-keyword: timezone-loaded:;
end class;

// LTD: Can't handle complex deftypes.
#f;

define method %valid-time-of-day? (timestamp)
  zero?(day-of(timestamp));
end method %valid-time-of-day?;

// LTD: Can't handle complex deftypes.
#f;

define method %valid-date? (timestamp)
  zero?(sec-of(timestamp)) & zero?(nsec-of(timestamp));
end method %valid-date?;

// LTD: Can't handle complex deftypes.
#f;

define class <invalid-timezone-file> (<error>)
  slot path-of, init-keyword: path:;
end class;

define class <invalid-time-specification> (<error>);
end class;

define class <invalid-timestring> (<error>)
  slot timestring-of, init-keyword: timestring:;
  slot failure-of, init-keyword: failure:;
end class;

define method make-load-form (self :: <timestamp>, #key environment)
  // LTD: Function MAKE-LOAD-FORM-SAVING-SLOTS not yet implemented.
  make-load-form-saving-slots(self, environment: environment);
end method make-load-form;

//  Declaims
// 
//  Variables
#f;

define variable *default-timezone-repository-path* =
  begin
    let try
        = method (project-home-directory)
            if (project-home-directory)
              block (nil)
                // LTD: Function TRUENAME not yet implemented.
                truename(// LTD: Function MERGE-PATHNAMES not yet implemented.
                         merge-pathnames("zoneinfo/",
                                         // LTD: Function MAKE-PATHNAME not yet implemented.
                                         make-pathname(directory: // LTD: Function PATHNAME-DIRECTORY not yet implemented.
                                                                  pathname-directory(project-home-directory))));
              exception (<error>)
                #f;
              end block;
            end if;
          end method;
    if (// LTD: Function FIND-PACKAGE not yet implemented.
        find-package("ASDF"))
      let path
          = // LTD: Function EVAL not yet implemented.
            eval(// LTD: Function READ-FROM-STRING not yet implemented.
                 read-from-string("(let ((system (asdf:find-system :local-time nil)))\n                                (when system\n                                  (asdf:component-pathname system)))"));
      try(path);
    end if
     | begin
         let path = (#f | *load-truename*);
         if (path)
           try(// LTD: Function MERGE-PATHNAMES not yet implemented.
               merge-pathnames("../", path));
         end if;
       end;
  end;

//  Month information
define variable +month-names+ =
  #["", "January", "February", "March", "April", "May", "June", "July", "August",
    "September", "October", "November", "December"];

define variable +short-month-names+ =
  #["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov",
    "Dec"];

define variable +day-names+ =
  #["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

define variable +day-names-as-keywords+ =
  #[#"sunday", #"monday", #"tuesday", #"wednesday", #"thursday", #"friday", #"saturday"];

define variable +short-day-names+ = #["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

define variable +minimal-day-names+ = #["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];

begin
  define constant +months-per-year+ = 12;
  define constant +days-per-week+ = 7;
  define constant +hours-per-day+ = 24;
  define constant +minutes-per-day+ = 1440;
  define constant +minutes-per-hour+ = 60;
  define constant +seconds-per-day+ = 86400;
  define constant +seconds-per-hour+ = 3600;
  define constant +seconds-per-minute+ = 60;
  define constant +usecs-per-day+ = 86400000000;
end;

define variable +iso-8601-date-format+ =
  #(#(#"year", 4), '-', #(#"month", 2), '-', #(#"day", 2));

define variable +iso-8601-time-format+ =
  #(#(#"hour", 2), ':', #(#"min", 2), ':', #(#"sec", 2), '.', #(#"usec", 6));

define variable +iso-8601-format+ =
  //  2008-11-18T02:32:00.586931+01:00
  concatenate(+iso-8601-date-format+, list('T'), +iso-8601-time-format+,
              list(#"gmt-offset-or-z"));

define variable +rfc3339-format+ = +iso-8601-format+;

define variable +rfc3339-format/date-only+ =
  #(#(#"year", 4), '-', #(#"month", 2), '-', #(#"day", 2));

define variable +asctime-format+ =
  #(#"short-weekday", ' ', #"short-month", ' ', #(#"day", 2, ' '), ' ', #(#"hour", 2),
    ':', #(#"min", 2), ':', #(#"sec", 2), ' ', #(#"year", 4));

// See the RFC 1123 for the details about the possible values of the timezone field.
define variable +rfc-1123-format+ =
  //  Sun, 06 Nov 1994 08:49:37 GMT
  #(#"short-weekday", ", ", #(#"day", 2), ' ', #"short-month", ' ', #(#"year", 4), ' ',
    #(#"hour", 2), ':', #(#"min", 2), ':', #(#"sec", 2), ' ', #"gmt-offset-hhmm");

define variable +iso-week-date-format+ =
  //  2009-W53-5
  #(#(#"iso-week-year", 4), '-', 'W', #(#"iso-week-number", 2), '-',
    #(#"iso-week-day", 1));

begin
  define variable +rotated-month-days-without-leap-day+ =
    #[31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28];
  define variable +rotated-month-offsets-without-leap-day+ =
    as(// LTD: Can't convert type specification.
       simple-array(fixnum, \*()),
       pair(0,
            begin
              let sum = 0;
              let _acc = make(<deque>);
              for (days in %rotated-month-days-without-leap-day+)
                push-last(_acc, inc!(sum, days));
              finally
                _acc;
              end for;
            end));
end;

//  The astronomical julian date offset is the number of days between
//  the current date and -4713-01-01T00:00:00+00:00
define variable +astronomical-julian-date-offset+ = -2451605;

//  The modified julian date is the number of days between the current
//  date and 1858-11-17T12:00:00+00:00. TODO: For the sake of simplicity,
//  we currently just do the date arithmetic and don't adjust for the
//  time of day.
define variable +modified-julian-date-offset+ = -51604;

define method %guess-offset (seconds, days, #key timezone)
  let zone = %realize-timezone(timezone | *default-timezone*);
  let unix-time = timestamp-values-to-unix(seconds, days);
  let subzone-idx
      = if (zero?(size(zone.timezone-indexes)))
          0;
        else
          zone
          .timezone-indexes[transition-position(unix-time, zone.timezone-transitions)];
        end if;
  let subzone = zone.timezone-subzones[subzone-idx];
  subzone.subzone-offset;
end method %guess-offset;

define method %read-binary-integer (stream, byte-count, #key signed = #f)
  // Read BYTE-COUNT bytes from the binary stream STREAM, and return an integer which is its representation in network byte order (MSB).  If SIGNED is true, interprets the most significant bit as a sign indicator.
  let result = 0;
  block (return)
    for (offset from (byte-count - 1) * 8 to 0 by 8)
      // LTD: Function LDB not yet implemented.
      ldb(// LTD: Function BYTE not yet implemented.
          byte(8, offset),
          result)
       := read-element(stream, nil);
    finally
      if (signed)
        let high-bit = byte-count * 8;
        if (logbit?(high-bit - 1, result))
          return(result - ash(1, high-bit));
        else
          return(result);
        end if;
      else
        return(result);
      end if;
      #f;
    end for;
  end block;
end method %read-binary-integer;

define method %string-from-unsigned-byte-vector (vector, offset)
  // Returns a string created from the vector of unsigned bytes VECTOR starting at OFFSET which is terminated by a 0.
  let null-pos
      = find-key(copy-subsequence(vector, start: offset), curry(\==, 0)) | size(vector);
  let result = make(<string>, size: null-pos - offset, fill: ' ');
  for (input-index from offset to null-pos - 1, output-index from 0)
    result[output-index] := as(<character>, vector[input-index]);
  end for;
  result;
end method %string-from-unsigned-byte-vector;

define method %find-first-std-offset (timezone-indexes, timestamp-info)
  let subzone-idx
      = cl-find-if(#"subzone-daylight-p", timezone-indexes,
                   key: method (x) timestamp-info[x]; end method);
  subzone-offset(timestamp-info[subzone-idx | 0]);
end method %find-first-std-offset;

define method %tz-verify-magic-number (inf, zone)
  let magic-buf = make(<vector>, size: 4);
  read-sequence(magic-buf, inf, start: 0, end: 4);
  if (/=(map-as(<string>, method (i) as(<character>, i); end method, magic-buf), "TZif",
         end1: 4))
    error(// LTD: Can't convert type specification.
          #"invalid-timezone-file", path: zone.timezone-path);
  end if;
  let ignore-buf = make(<vector>, size: 16);
  read-sequence(ignore-buf, inf, start: 0, end: 16);
end method %tz-verify-magic-number;

define method %tz-read-header (inf)
  list(utc-count: %read-binary-integer(inf, 4),
       wall-count: %read-binary-integer(inf, 4),
       leap-count: %read-binary-integer(inf, 4),
       transition-count: %read-binary-integer(inf, 4),
       type-count: %read-binary-integer(inf, 4),
       abbrev-length: %read-binary-integer(inf, 4));
end method %tz-read-header;

define method %tz-read-transitions (inf, count)
  make(<array>, dimensions: count);
end method %tz-read-transitions;

define method %tz-read-indexes (inf, count)
  make(<array>, dimensions: count);
end method %tz-read-indexes;

define method %tz-read-subzone (inf, count)
  let _acc = make(<deque>);
  for (idx from 1 to count)
    push-last(_acc,
              list(%read-binary-integer(inf, 4, #t), %read-binary-integer(inf, 1),
                   %read-binary-integer(inf, 1)));
  finally
    _acc;
  end for;
end method %tz-read-subzone;

define method leap-seconds-sec (leap-seconds)
  head(leap-seconds);
end method leap-seconds-sec;

define method leap-seconds-adjustment (leap-seconds)
  tail(leap-seconds);
end method leap-seconds-adjustment;

define method %tz-read-leap-seconds (inf, count)
  if (positive?(count))
    let sec = make(<deque>);
    let adjustment = make(<deque>);
    block (return)
      for (idx from 1 to count)
        push-last(sec, %read-binary-integer(inf, 4));
        push-last(adjustment, %read-binary-integer(inf, 4));
      finally
        return(pair(make(<array>, dimensions: count),
                    make(<array>, dimensions: count)));
        sec;
      end for;
    end block;
  end if;
end method %tz-read-leap-seconds;

define method %tz-read-abbrevs (inf, length)
  let a = make(<array>, dimensions: length);
  read-sequence(a, inf, start: 0, end: length);
  a;
end method %tz-read-abbrevs;

define method %tz-read-indicators (inf, length)
  let buf = make(<array>, dimensions: length);
  read-sequence(buf, inf, start: 0, end: length);
  make(<array>, dimensions: length);
end method %tz-read-indicators;

define method %tz-make-subzones (raw-info, abbrevs, gmt-indicators, std-indicators)
  // (declare (ignore gmt-indicators std-indicators))
  //  TODO: handle TZ environment variables, which use the gmt and std
  //  indicators
  make(<vector>, size: size(raw-info));
end method %tz-make-subzones;

define method %realize-timezone (zone, #key reload)
  // If timezone has not already been loaded or RELOAD is non-NIL, loads the timezone information from its associated unix file.  If the file is not a valid timezone file, the condition INVALID-TIMEZONE-FILE will be signaled.
  if (reload | ~ zone.timezone-loaded)
    with-open-file (inf
                     = (zone.timezone-path, direction: #"input",
                        element-type: #"unsigned-byte"))
      %tz-verify-magic-number(inf, zone);
      let header = %tz-read-header(inf);
      let timezone-transitions
          = %tz-read-transitions(inf, get-property!(header, #"transition-count"));
      let subzone-indexes
          = %tz-read-indexes(inf, get-property!(header, #"transition-count"));
      let subzone-raw-info
          = %tz-read-subzone(inf, get-property!(header, #"type-count"));
      let abbreviation-buf
          = %tz-read-abbrevs(inf, get-property!(header, #"abbrev-length"));
      let leap-second-info
          = %tz-read-leap-seconds(inf, get-property!(header, #"leap-count"));
      let std-indicators
          = %tz-read-indicators(inf, get-property!(header, #"wall-count"));
      let gmt-indicators
          = %tz-read-indicators(inf, get-property!(header, #"utc-count"));
      let subzone-info
          = %tz-make-subzones(subzone-raw-info, abbreviation-buf, gmt-indicators,
                              std-indicators);
      zone.timezone-transitions := timezone-transitions;
      zone.timezone-indexes := subzone-indexes;
      zone.timezone-subzones := subzone-info;
      zone.timezone-leap-seconds := leap-second-info;
      zone.timezone-loaded := #t;
    end with-open-file;
  end if;
  zone;
end method %realize-timezone;

begin
  define method %make-simple-timezone (name, abbrev, offset)
    let subzone = make-subzone(offset: offset, daylight-p: #f, abbrev: abbrev);
    make-timezone(subzones: make(<vector>, size: 1), path: #f, name: name, loaded: #t);
  end method %make-simple-timezone;
  //  to be used as #+#.(local-time::package-with-symbol? "SB-EXT" "GET-TIME-OF-DAY")
  define method package-with-symbol? (package, name)
    if (// LTD: Function FIND-PACKAGE not yet implemented.
        find-package(package)
         & // LTD: Function FIND-SYMBOL not yet implemented.
           find-symbol(name, package))
      #(#"and");
    else
      #(#"or");
    end if;
  end method package-with-symbol?;
end;

define variable +utc-zone+ =
  %make-simple-timezone("Coordinated Universal Time", "UTC", 0);

define variable +gmt-zone+ = %make-simple-timezone("Greenwich Mean Time", "GMT", 0);

define variable +none-zone+ = %make-simple-timezone("Explicit Offset Given", "NONE", 0);

// LTD: No macros.
#"define-timezone";

begin
  let default-timezone-file = #P"/etc/localtime";
  // LTD: Function HANDLER-CASE not yet implemented.
  handler-case(begin
                 let g760
                     = define variable *default-timezone* =
                         make-timezone(path: default-timezone-file,
                                       name: "*default-timezone*");
                 %realize-timezone(*default-timezone*);
                 g760;
               end,
               t(#(), *default-timezone* := +utc-zone+));
end;

// A hashtable with entries like "Europe/Budapest" -> timezone-instance
define variable *location-name->timezone* = make(<equal-table>, test: \=);

// A hashtable of "CEST" -> list of timezones with "CEST" subzone
define variable *abbreviated-subzone-name->timezone-list* = make(<equal-table>, test: \=);

define method find-timezone-by-location-name (name)
  if (zero?(size(*location-name->timezone*)))
    error("Seems like the timezone repository has not yet been loaded. Hint: see REREAD-TIMEZONE-REPOSITORY.");
  end if;
  *location-name->timezone*[name];
end method find-timezone-by-location-name;

define method timezone= (timezone-1, timezone-2)
  // Return two values indicating the relationship between timezone-1 and timezone-2. The first value is whether the two timezones are equal and the second value indicates whether it is sure or not.
  // 
  // In other words:
  // (values t t) means timezone-1 and timezone-2 are definitely equal.
  // (values nil t) means timezone-1 and timezone-2 are definitely different.
  // (values nil nil) means that it couldn't be determined.
  if (timezone-1 == timezone-2 | timezone-1 = timezone-2)
    values(#t, #t);
  else
    values(#f, #f);
  end if;
end method timezone=;

define method reread-timezone-repository (#key timezone-repository
                                                = *default-timezone-repository-path*)
  check-type(timezone-repository, pathname | string);
  let root-directory = directory-exists-p(timezone-repository);
  if (~ root-directory)
    error("REREAD-TIMEZONE-REPOSITORY was called with invalid PROJECT-DIRECTORY (%S).",
          timezone-repository);
  end if;
  let cutoff-position
      = size(// LTD: Function PRINC-TO-STRING not yet implemented.
             princ-to-string(root-directory));
  let visitor
      = method (file)
          // LTD: Function HANDLER-CASE not yet implemented.
          handler-case(begin
                         let full-name
                             = copy-sequence(// LTD: Function PRINC-TO-STRING not yet implemented.
                                             princ-to-string(file),
                                             cutoff-position);
                         let name
                             = // LTD: Function PATHNAME-NAME not yet implemented.
                               pathname-name(file);
                         let timezone
                             = %realize-timezone(make-timezone(path: file, name: name));
                         *location-name->timezone*[full-name] := timezone;
                         map-as(#f,
                                method (subzone)
                                  push!(timezone,
                                        *abbreviated-subzone-name->timezone-list*[subzone
                                                                                  .subzone-abbrev]);
                                end method,
                                timezone.timezone-subzones);
                       end,
                       invalid-timezone-file(#(), #f));
        end method;
  *location-name->timezone* := make(<equal-table>, test: \=);
  *abbreviated-subzone-name->timezone-list* := make(<equal-table>, test: \=);
  walk-directory(root-directory, visitor, directories: #f,
                 test: method (file)
                         ~ cl-find("Etc",
                                   // LTD: Function PATHNAME-DIRECTORY not yet implemented.
                                   pathname-directory(file),
                                   test: \=);
                       end method,
                 follow-symlinks: #f);
  walk-directory(// LTD: Function MERGE-PATHNAMES not yet implemented.
                 merge-pathnames("Etc/", root-directory),
                 visitor, directories: #f);
end method reread-timezone-repository;

// LTD: No macros.
#"make-timestamp";

define method clone-timestamp (timestamp)
  make(<timestamp>, nsec: nsec-of(timestamp), sec: sec-of(timestamp),
       day: day-of(timestamp));
end method clone-timestamp;

define method transition-position (needle, haystack)
  let start = 0;
  let end = size(haystack) - 1;
  block (return)
    for (middle = floor/(end + start, 2) then floor/(end + start, 2),
         while start < end & needle ~= haystack[middle])
      if (needle > haystack[middle])
        start := middle + 1;
      else
        end := middle - 1;
      end if;
    finally
      return(max(0,
                 if (negative?(end))
                   0;
                 elseif (needle = haystack[middle])
                   middle;
                 elseif (needle >= haystack[end])
                   end;
                 else
                   end - 1;
                 end if));
      #f;
    end for;
  end block;
end method transition-position;

define method timestamp-subtimezone (timestamp, timezone)
  // Return as multiple values the time zone as the number of seconds east of UTC, a boolean daylight-saving-p, and the customary abbreviation of the timezone.
  let zone = %realize-timezone(timezone | *default-timezone*);
  let unix-time = timestamp-to-unix(timestamp);
  let subzone-idx
      = if (zero?(size(zone.timezone-indexes)))
          0;
        else
          zone
          .timezone-indexes[transition-position(unix-time, zone.timezone-transitions)];
        end if;
  let subzone = zone.timezone-subzones[subzone-idx];
  values(subzone.subzone-offset, subzone.subzone-daylight-p, subzone.subzone-abbrev);
end method timestamp-subtimezone;

define method %adjust-to-offset (sec, day, offset)
  // Returns two values, the values of new DAY and SEC slots of the timestamp adjusted to the given timezone.
  // (declare (type integer sec day offset))
  let (offset-day, offset-sec) = truncate/(offset, $seconds-per-day);
  let new-sec = sec + offset-sec;
  let new-day = day + offset-day;
  if (negative?(new-sec))
    inc!(new-sec, $seconds-per-day);
    dec!(new-day);
  elseif (new-sec >= $seconds-per-day)
    inc!(new-day);
    dec!(new-sec, $seconds-per-day);
  end if;
  values(new-sec, new-day);
end method %adjust-to-offset;

define method %adjust-to-timezone (source, timezone, #key offset)
  %adjust-to-offset(sec-of(source), day-of(source),
                    offset | timestamp-subtimezone(source, timezone));
end method %adjust-to-timezone;

define method timestamp-minimize-part (timestamp, part,
                                       #key timezone = *default-timezone*, into)
  let timestamp-parts = #(#"nsec", #"sec", #"min", #"hour", #"day", #"month");
  let part-count = find-key(timestamp-parts, curry(\==, part));
  assert(part-count);
  let (nsec, sec, min, hour, day, month, year, day-of-week, daylight-saving-time-p,
       offset)
      = decode-timestamp(timestamp, timezone: timezone);
  // (declare (ignore nsec day-of-week daylight-saving-time-p))
  encode-timestamp(0, if (part-count > 0) 0; else sec; end if,
                   if (part-count > 1) 0; else min; end if,
                   if (part-count > 2) 0; else hour; end if,
                   if (part-count > 3) 1; else day; end if,
                   if (part-count > 4) 1; else month; end if, year,
                   offset: if (timezone) #f; else offset; end if, timezone: timezone,
                   into: into);
end method timestamp-minimize-part;

define method timestamp-maximize-part (timestamp, part,
                                       #key timezone = *default-timezone*, into)
  let timestamp-parts = #(#"nsec", #"sec", #"min", #"hour", #"day", #"month");
  let part-count = find-key(timestamp-parts, curry(\==, part));
  assert(part-count);
  let (nsec, sec, min, hour, day, month, year, day-of-week, daylight-saving-time-p,
       offset)
      = decode-timestamp(timestamp, timezone: timezone);
  let month = if (part-count > 4) 12; else month; end if;
  encode-timestamp(999999999, if (part-count > 0) 59; else sec; end if,
                   if (part-count > 1) 59; else min; end if,
                   if (part-count > 2) 23; else hour; end if,
                   if (part-count > 3) days-in-month(month, year); else day; end if,
                   month, year, offset: if (timezone) #f; else offset; end if,
                   timezone: timezone, into: into);
end method timestamp-maximize-part;

// LTD: No macros.
#"with-decoded-timestamp";

define method %normalize-month-year-pair (month, year)
  // Normalizes the month/year pair: in case month is < 1 or > 12 the month and year are corrected to handle the overflow.
  let (year-offset, month-minus-one) = floor/(month - 1, 12);
  values(month-minus-one + 1, year + year-offset);
end method %normalize-month-year-pair;

define method days-in-month (month, year)
  // Returns the number of days in the given month of the specified year.
  let normal-days = +rotated-month-days-without-leap-day+[modulo(month + 9, 12)];
  if (month = 2
       & (zero?(modulo(year, 4)) & positive?(modulo(year, 100))
           | zero?(modulo(year, 400))))
    normal-days + 1;
  else
    //  February on a leap year
    normal-days;
  end if;
end method days-in-month;

//  TODO scan all uses of FIX-OVERFLOW-IN-DAYS and decide where it's ok to silently fix and where should be and error reported
define method %fix-overflow-in-days (day, month, year)
  // In case the day number is higher than the maximal possible for the given month/year pair, returns the last day of the month.
  let max-day = days-in-month(month, year);
  if (day > max-day) max-day; else day; end if;
end method %fix-overflow-in-days;

begin
  define method %list-length= (num, list)
    // Tests for a list of length NUM without traversing the entire list to get the length.
    let c = nth-tail(list, num - 1);
    c & not(pair?(tail(c)));
  end method %list-length=;
  define method %expand-adjust-timestamp-changes (timestamp, changes, visitor)
    let params = #();
    let functions = #();
    for (change in changes)
      begin
        assert(%list-length=(3, change)
                | (%list-length=(2, change) & instance?(first(change), <symbol>)
                    & (first(change) = #"timezone" | first(change) = #"utc-offset"))
                | (%list-length=(4, change) & instance?(third(change), <symbol>)
                    & (third(change) = #"to" | third(change) = #"by")));
        let operation = first(change);
        let part = second(change);
        let value = if (%list-length=(3, change)) third(change); else change[3]; end if;
        if (operation = #"set")
          push!(list(#"%set-timestamp-part", part, value), functions);
        elseif (operation = #"offset")
          push!(list(#"%offset-timestamp-part", part, value), functions);
        elseif (operation = #"utc-offset")
          push!(part, params);
          push!(utc-offset: params);
        elseif (operation = #"timezone")
          push!(part, params);
          push!(timezone: params);
        else
          error("Unexpected operation %=", operation);
        end if;
      end;
    finally
      begin
        let function = #f;
        let part = #f;
        let value = #f;
        let loop-list-761 = functions;
        local method go-end-loop () #f; end method go-end-loop,
              method go-next-loop ()
                if (not(pair?(loop-list-761))) go-end-loop(); end if;
                let loop-desetq-temp = head(loop-list-761);
                function := head(loop-desetq-temp);
                loop-desetq-temp := tail(loop-desetq-temp);
                part := head(loop-desetq-temp);
                loop-desetq-temp := tail(loop-desetq-temp);
                value := head(loop-desetq-temp);
                loop-list-761 := tail(loop-list-761);
                visitor(apply(list, function, timestamp, part, value, params));
                go-next-loop();
                go-end-loop();
              end method go-next-loop;
        go-next-loop();
      end;
      #f;
    end for;
  end method %expand-adjust-timestamp-changes;
  define method %expand-adjust-timestamp (timestamp, changes, #key functional)
    let old = generate-symbol(#"string"("OLD"));
    let new = if (functional) generate-symbol(#"string"("NEW")); else old; end if;
    let forms = list();
    %expand-adjust-timestamp-changes(old, changes,
                                     method (change)
                                       push!(apply(list, #"progn",
                                                   list(#"multiple-value-bind",
                                                        #(#"nsec", #"sec", #"day"),
                                                        change,
                                                        apply(list, #"setf",
                                                              list(#"nsec-of", new),
                                                              #(#"nsec")),
                                                        apply(list, #"setf",
                                                              list(#"sec-of", new),
                                                              #(#"sec")),
                                                        apply(list, #"setf",
                                                              list(#"day-of", new),
                                                              #(#"day"))),
                                                   if (functional)
                                                     list(list(#"setf", old, new));
                                                   end if),
                                             forms);
                                     end method);
    forms := reverse!(forms);
    apply(list, #"let*",
          apply(list, list(old, timestamp),
                if (functional) list(list(new, list(#"clone-timestamp", old))); end if),
          concatenate(forms, list(old)));
  end method %expand-adjust-timestamp;
end;

//  eval-when
// LTD: No macros.
#"adjust-timestamp";

// LTD: No macros.
#"adjust-timestamp!";

define method %set-timestamp-part (time, part, new-value,
                                   #key timezone = *default-timezone*, utc-offset)
  //  TODO think about error signalling. when, how to disable if it makes sense, ...
  select (part)
    (#"nsec", #"sec-of-day", #"day")
       => let nsec = nsec-of(time);
           let sec = sec-of(time);
           let day = day-of(time);
           select (part)
             #"nsec"
                => nsec := as(limited(<integer>, min: 0, max: 999999999), new-value);
             #"sec-of-day"
                => sec := as(list(#"integer", 0, $seconds-per-day), new-value);
             #"day"
                => day := new-value;
             otherwise
                => #f;
           end select;
           values(nsec, sec, day);
    otherwise
       => apply(method (#key nsec = #f, sec = #f, minute = #f, hour = #f, day = #f,
                        month = #f, year = #f, g762 = #f, g763 = #f, #rest g764)
                  select (part)
                    #"sec"
                       => sec := new-value;
                    #"minute"
                       => minute := new-value;
                    #"hour"
                       => hour := new-value;
                    #"day-of-month"
                       => day := new-value;
                    #"month"
                       => month := new-value;
                           day := %fix-overflow-in-days(day, month, year);
                    #"year"
                       => year := new-value;
                           day := %fix-overflow-in-days(day, month, year);
                  end select;
                  encode-timestamp-into-values(nsec, sec, minute, hour, day, month,
                                               year, timezone: timezone,
                                               offset: utc-offset);
                end method,
                concatenate!(begin
                               let (#rest _)
                                   = decode-timestamp(time, timezone: timezone,
                                                      offset: utc-offset);
                               _;
                             end));
  end select;
end method %set-timestamp-part;

define method %offset-timestamp-part (time, part, offset,
                                      #key timezone = *default-timezone*, utc-offset)
  // Returns a time adjusted by the specified OFFSET. Takes care of
  // different kinds of overflows. The setting :day-of-week is possible
  // using a keyword symbol name of a week-day (see
  // +DAY-NAMES-AS-KEYWORDS+) as value. In that case point the result to
  // day given by OFFSET in the week that contains TIME.
  local method direct-adjust (part, offset, nsec, sec, day)
          block (return-from-direct-adjust)
            if (part == #"day-of-week")
              apply(method (#key nsec = #f, sec = #f, minute = #f, hour = #f, day = #f,
                            month = #f, year = #f, day-of-week = #f, g765 = #f,
                            #rest g766)
                      let position
                          = find-key(+day-names-as-keywords+, curry(\==, offset));
                      assert(position);
                      let offset
                          = - if (zerop(day-of-week)) 7; day-of-week; end if + position;
                      inc!(day, offset);
                      if (day < 1)
                        dec!(month);
                        if (month < 1) month := 12; dec!(year); end if;
                        day := days-in-month(month, year) + day;
                      else
                        begin
                          let days-in-month = days-in-month(month, year);
                          if (days-in-month < day)
                            inc!(month);
                            if (month = 13) month := 1; inc!(year); end if;
                            dec!(day, days-in-month);
                          end if;
                        end;
                      end if;
                      encode-timestamp-into-values(nsec, sec, minute, hour, day, month,
                                                   year, timezone: timezone,
                                                   offset: utc-offset);
                    end method,
                    concatenate!(begin
                                   let (#rest _)
                                       = decode-timestamp(time, timezone: timezone,
                                                          offset: utc-offset);
                                   _;
                                 end));
            elseif (zero?(offset))
              //  The offset is zero, so just return the parts of the timestamp object
              values(nsec, sec, day);
            else
              begin
                let old-utc-offset = utc-offset | timestamp-subtimezone(time, timezone);
                let new-utc-offset = #f;
                local method go-top ()
                        select (part)
                          #"nsec"
                             => let (sec-offset, new-nsec)
                                    = floor/(offset + nsec, 1000000000);
                                 //  the time might need to be adjusted a bit more if q != 0
                                 begin
                                   part := #"sec";
                                   offset := sec-offset;
                                   nsec := new-nsec;
                                 end;
                                 go-top();
                          (#"sec", #"minute", #"hour")
                             => let (days-offset, new-sec)
                                    = floor/(sec
                                              + offset
                                                 * select (part)
                                                     #"sec"
                                                        => 1;
                                                     #"minute"
                                                        => $seconds-per-minute;
                                                     #"hour"
                                                        => $seconds-per-hour;
                                                   end select,
                                             $seconds-per-day);
                                 return-from-direct-adjust(nsec, new-sec,
                                                           day + days-offset);
                          #"day"
                             => inc!(day, offset);
                                 new-utc-offset
                                  := utc-offset
                                      | timestamp-subtimezone(make(<timestamp>,
                                                                   nsec: nsec, sec: sec,
                                                                   day: day),
                                                              timezone);
                                 if (~ (old-utc-offset = new-utc-offset))
                                   //  We hit the DST boundary. We need to restart again
                                   //  with :sec, but this time we know both old and new
                                   //  UTC offset will be the same, so it's safe to do
                                   begin
                                     part := #"sec";
                                     offset := old-utc-offset - new-utc-offset;
                                     old-utc-offset := new-utc-offset;
                                   end;
                                   go-top();
                                 end if;
                                 return-from-direct-adjust(nsec, sec, day);
                        end select;
                      end method go-top;
                go-top();
              end;
            end if;
          end block;
        end method direct-adjust,
        method safe-adjust (part, offset, time)
          apply(method (#key nsec = #f, sec = #f, minute = #f, hour = #f, day = #f,
                        month = #f, year = #f, g767 = #f, g768 = #f, #rest g769)
                  let (month-new, year-new)
                      = %normalize-month-year-pair(select (part)
                                                     #"month"
                                                        => offset;
                                                     #"year"
                                                        => 12 * offset;
                                                   end select
                                                    + month,
                                                   year);
                  encode-timestamp-into-values(nsec, sec, minute, hour,
                                               %fix-overflow-in-days(day, month-new,
                                                                     year-new),
                                               month-new, year-new, timezone: timezone,
                                               offset: utc-offset);
                end method,
                concatenate!(begin
                               let (#rest _)
                                   = decode-timestamp(time, timezone: timezone,
                                                      offset: utc-offset);
                               _;
                             end));
        end method safe-adjust;
  select (part)
    (#"nsec", #"sec", #"minute", #"hour", #"day", #"day-of-week")
       => direct-adjust(part, offset, nsec-of(time), sec-of(time), day-of(time));
    (#"month", #"year")
       => safe-adjust(part, offset, time);
  end select;
end method %offset-timestamp-part;

//  TODO merge this functionality into timestamp-difference
define method timestamp-whole-year-difference (time-a, time-b)
  // Returns the number of whole years elapsed between time-a and time-b (hint: anniversaries).
  let (nsec-b, sec-b, minute-b, hour-b, day-b, month-b, year-b, day-of-week-b,
       daylight-p-b, offset-b)
      = decode-timestamp(time-b);
  let (nsec-a, sec-a, minute-a, hour-a, day-a, month-a, year-a)
      = decode-timestamp(time-a);
  let year-difference = year-a - year-b;
  if (timestamp<=(encode-timestamp(nsec-b, sec-b, minute-b, hour-b,
                                   if (month-b = 2) min(28, day-b); else day-b; end if,
                                   month-b, year-difference + year-b, offset: offset-b),
                  time-a))
    year-difference;
  else
    year-difference - 1;
  end if;
end method timestamp-whole-year-difference;

define method timestamp-difference (time-a, time-b)
  // Returns the difference between TIME-A and TIME-B in seconds
  let nsec = nsec-of(time-a) - nsec-of(time-b);
  let second = sec-of(time-a) - sec-of(time-b);
  let day = day-of(time-a) - day-of(time-b);
  if (negative?(nsec)) dec!(second); inc!(nsec, 1000000000); end if;
  if (negative?(second)) dec!(day); inc!(second, $seconds-per-day); end if;
  let result = day * $seconds-per-day + second;
  if (~ zero?(nsec))
    //  this incf turns the result into a float, so only do this when necessary
    inc!(result, nsec / 1.0d9);
  end if;
  result;
end method timestamp-difference;

define method timestamp+ (time, amount, unit, #key timezone = *default-timezone*,
                          offset)
  let (nsec, sec, day)
      = %offset-timestamp-part(time, unit, amount, timezone: timezone,
                               utc-offset: offset);
  make(<timestamp>, nsec: nsec, sec: sec, day: day);
end method timestamp+;

define method timestamp- (time, amount, unit, #key timezone = *default-timezone*,
                          offset)
  timestamp+(time, - amount, unit, timezone, offset);
end method timestamp-;

define method timestamp-day-of-week (timestamp, #key timezone = *default-timezone*,
                                     offset)
  modulo(3
          + begin
              let (#rest _) = %adjust-to-timezone(timestamp, timezone, offset);
              _;
            end[1],
         7);
end method timestamp-day-of-week;

//  TODO read
//  http://java.sun.com/j2se/1.4.2/docs/api/java/util/GregorianCalendar.html
//  (or something else, sorry :) this scheme only works back until
//  1582, the start of the gregorian calendar.  see also
//  DECODE-TIMESTAMP when fixing if fixing is desired at all.
define method valid-timestamp-p (nsec, sec, minute, hour, day, month, year)
  // Returns T if the time values refer to a valid time, otherwise returns NIL.
  0 <= nsec & nsec <= 999999999 & (0 <= sec & sec <= 59) & (0 <= minute & minute <= 59)
   & (0 <= hour & hour <= 23)
   & (1 <= month & month <= 12)
   & (1 <= day & day <= days-in-month(month, year))
   & year ~= 0;
end method valid-timestamp-p;

define method encode-timestamp-into-values (nsec, sec, minute, hour, day, month, year,
                                            #key timezone = *default-timezone*, offset)
  // Returns (VALUES NSEC SEC DAY ZONE) ready to be used for
  // instantiating a new timestamp object.  If the specified time is
  // invalid, the condition INVALID-TIME-SPECIFICATION is raised.
  //  If the user provided an explicit offset, we use that.  Otherwise,
  //
  #f;
  let 0-based-rotated-month = if (month >= 3) month - 3; else month + 9; end if;
  let internal-year = if (month < 3) year - 2001; else year - 2000; end if;
  let years-as-days = years-to-days(internal-year);
  let sec = hour * $seconds-per-hour + minute * $seconds-per-minute + sec;
  let days-from-zero-point
      = years-as-days + +rotated-month-offsets-without-leap-day+[0-based-rotated-month]
         + (day - 1);
  let used-offset = offset | %guess-offset(sec, days-from-zero-point, timezone);
  let (utc-sec, utc-day) = %adjust-to-offset(sec, days-from-zero-point, - used-offset);
  values(nsec, utc-sec, utc-day);
end method encode-timestamp-into-values;

define method encode-timestamp (nsec, sec, minute, hour, day, month, year,
                                #key timezone = *default-timezone*, offset, into)
  // Return a new TIMESTAMP instance corresponding to the specified time
  // elements.
  let (nsec, sec, day)
      = encode-timestamp-into-values(nsec, sec, minute, hour, day, month, year,
                                     timezone: timezone, offset: offset);
  if (into)
    nsec-of(into) := nsec;
    sec-of(into) := sec;
    day-of(into) := day;
    into;
  else
    make(<timestamp>, nsec: nsec, sec: sec, day: day);
  end if;
end method encode-timestamp;

define method universal-to-timestamp (universal, #key nsec = 0)
  // Returns a timestamp corresponding to the given universal time.
  let adjusted-universal = universal - 3160857600;
  let (day, second) = floor/(adjusted-universal, $seconds-per-day);
  make(<timestamp>, day: day, sec: second, nsec: nsec);
end method universal-to-timestamp;

define method timestamp-to-universal (timestamp)
  // Return the UNIVERSAL-TIME corresponding to the TIMESTAMP
  //  universal time is seconds from 1900-01-01T00:00:00Z
  day-of(timestamp) * $seconds-per-day + sec-of(timestamp) + 3160857600;
end method timestamp-to-universal;

define method unix-to-timestamp (unix, #key nsec = 0)
  // Return a TIMESTAMP corresponding to UNIX, which is the number of seconds since the unix epoch, 1970-01-01T00:00:00Z.
  let (days, secs) = floor/(unix, $seconds-per-day);
  make(<timestamp>, day: days - 11017, sec: secs, nsec: nsec);
end method unix-to-timestamp;

define method timestamp-values-to-unix (seconds, day)
  // Return the Unix time correspondint to the values used to encode a TIMESTAMP
  (day + 11017) * $seconds-per-day + seconds;
end method timestamp-values-to-unix;

define method timestamp-to-unix (timestamp)
  // Return the Unix time corresponding to the TIMESTAMP
  timestamp-values-to-unix(sec-of(timestamp), day-of(timestamp));
end method timestamp-to-unix;

define method %get-current-time ()
  // Cross-implementation abstraction to get the current time measured from the unix epoch (1/1/1970). Should return (values sec nano-sec).
  //  available from sbcl 1.0.28.66
  let (sec, nsec) = get-time-of-day();
  values(sec, 1000 * nsec);
end method %get-current-time;

// Use the `*clock*' special variable if you need to define your own idea of the current time.
// 
// The value of this variable should have the methods `local-time::clock-now', and
// `local-time::clock-today'. The currently supported values in local-time are:
//   t - use the standard clock
//   local-time:leap-second-adjusted - use a clock which adjusts for leap seconds using the information in *default-timezone*.
define variable *clock* = #t;

define method now ()
  // Returns a timestamp representing the present moment.
  clock-now(*clock*);
end method now;

define method today ()
  // Returns a timestamp representing the present day.
  clock-today(*clock*);
end method today;

// Returns a timestamp for the current time given a clock.
define generic clock-now (clock) ;

// Returns a timestamp for the current date given a
//   clock.  The date is encoded by convention as a timestamp with the
//   time set to 00:00:00UTC.
define generic clock-today (clock) ;

define method %leap-seconds-offset (leap-seconds, sec)
  // Find the latest leap second adjustment effective at SEC system time.
  leap-seconds-adjustment(leap-seconds)[transition-position(sec,
                                                            leap-seconds-sec(leap-seconds))];
end method %leap-seconds-offset;

define method %adjust-sec-for-leap-seconds (sec)
  // Ajdust SEC from system time to Unix time (on systems those clock does not jump back over leap seconds).
  let leap-seconds = timezone-leap-seconds(%realize-timezone(*default-timezone*));
  if (leap-seconds) dec!(sec, %leap-seconds-offset(leap-seconds, sec)); end if;
  sec;
end method %adjust-sec-for-leap-seconds;

define method clock-now (clock :: singleton(#"leap-second-adjusted"))
  let (sec, nsec) = %get-current-time();
  unix-to-timestamp(%adjust-sec-for-leap-seconds(sec), nsec: nsec);
end method clock-now;

define method clock-now (clock)
  let (sec, nsec) = %get-current-time();
  unix-to-timestamp(sec, nsec: nsec);
end method clock-now;

define method clock-today (clock)
  let result = now();
  sec-of(result) := 0;
  nsec-of(result) := 0;
  result;
end method clock-today;

define method %timestamp-compare (time-a, time-b)
  // Returns the symbols <, >, or =, describing the relationship between TIME-A and TIME-b.
  if (day-of(time-a) < day-of(time-b))
    #"<";
  elseif (day-of(time-a) > day-of(time-b))
    #">";
  elseif (sec-of(time-a) < sec-of(time-b))
    #"<";
  elseif (sec-of(time-a) > sec-of(time-b))
    #">";
  elseif (nsec-of(time-a) < nsec-of(time-b))
    #"<";
  elseif (nsec-of(time-a) > nsec-of(time-b))
    #">";
  else
    #"=";
  end if;
end method %timestamp-compare;

define method timestamp/= (#rest timestamps)
  // Returns T if no pair of timestamps is equal. Otherwise return NIL.
  block (return-from-timestamp/=)
    for (ts-head = timestamps then tail(ts-head), until empty?(ts-head))
      for (ts in tail(ts-head))
        if (timestamp=(head(ts-head), ts)) return-from-timestamp/=(#f); end if;
      end for;
    end for;
    #t;
  end block;
end method timestamp/=;

define method contest (test, list)
  // Applies TEST to pairs of elements in list, keeping the element which last tested T.  Returns the winning element.
  reduce1(method (a, b) if (test(a, b)) a; else b; end if; end method, list);
end method contest;

define method timestamp-minimum (time, #rest times)
  // Returns the earliest timestamp
  contest(timestamp<, pair(time, times));
end method timestamp-minimum;

define method timestamp-maximum (time, #rest times)
  // Returns the latest timestamp
  contest(timestamp>, pair(time, times));
end method timestamp-maximum;

define method years-to-days (years)
  // Given a number of years, returns the number of days in those years.
  let days = years * 365;
  let l1 = floor/(years, 4);
  let l2 = floor/(years, 100);
  let l3 = floor/(years, 400);
  days + l1 + - l2 + l3;
end method years-to-days;

define method days-to-years (days)
  // Given a number of days, returns the number of years and the remaining days in that year.
  let remaining-days = days;
  let (400-years, remaining-days) = floor/(remaining-days, 146097);
  let 100-years = min(floor/(remaining-days, 36524), 3);
  let remaining-days = remaining-days - 100-years * 36524;
  let (4-years, remaining-days) = floor/(remaining-days, 1461);
  let years = min(3, floor/(remaining-days, 365));
  values(400-years * 400 + 100-years * 100 + 4-years * 4 + years,
         remaining-days - years * 365);
end method days-to-years;

define method %timestamp-decode-date (days)
  // Returns the year, month, and day, given the number of days from the epoch.
  let (years, remaining-days) = days-to-years(days);
  let leap-day-p = remaining-days = 365;
  let rotated-1-based-month
      = if (leap-day-p)
          12;
        else
          //  march is the first month and february is the last
          find-key(+rotated-month-offsets-without-leap-day+,
                   curry(\==, remaining-days));
        end if;
  let 1-based-month
      = if (rotated-1-based-month >= 11)
          rotated-1-based-month - 10;
        else
          rotated-1-based-month + 2;
        end if;
  let 1-based-day
      = if (leap-day-p)
          29;
        else
          remaining-days
           - +rotated-month-offsets-without-leap-day+[(rotated-1-based-month - 1)]
           + 1;
        end if;
  values(years
          + if ((rotated-1-based-month >= 11))
              //  january is in the next year
              2001;
            else
              2000;
            end if,
         1-based-month, 1-based-day);
end method %timestamp-decode-date;

define method %timestamp-decode-iso-week (timestamp)
  // Returns the year, week number, and day of week components of an ISO week date.
  let dn = timestamp-day-of-week(timestamp);
  let day-of-week = if (zero?(dn)) 7; else dn; end if;
  let nearest-thursday = timestamp+(timestamp, 4 - day-of-week, #"day");
  let year = timestamp-year(nearest-thursday);
  let month = timestamp-month(nearest-thursday);
  let day = timestamp-day(nearest-thursday);
  let ordinal-day
      = day-of(encode-timestamp(0, 0, 0, 0, day, month, year, timezone: +utc-zone+))
         - day-of(encode-timestamp(0, 0, 0, 0, 1, 1, year, timezone: +utc-zone+));
  values(year, floor/(ordinal-day, 7) + 1, day-of-week);
end method %timestamp-decode-iso-week;

define method %timestamp-decode-time (seconds)
  // Returns the hours, minutes, and seconds, given the number of seconds since midnight.
  let (hours, hour-remainder) = floor/(seconds, $seconds-per-hour);
  let (minutes, seconds) = floor/(hour-remainder, $seconds-per-minute);
  values(hours, minutes, seconds);
end method %timestamp-decode-time;

define method decode-timestamp (timestamp, #key timezone = *default-timezone*, offset)
  // Returns the decoded time as multiple values: nsec, ss, mm, hh, day, month, year, day-of-week
  let timezone = if (offset) +none-zone+; else timezone; end if;
  let (offset*, daylight-p, abbreviation) = timestamp-subtimezone(timestamp, timezone);
  let (adjusted-secs, adjusted-days) = %adjust-to-timezone(timestamp, timezone, offset);
  let (hours, minutes, seconds) = %timestamp-decode-time(adjusted-secs);
  let (year, month, day) = %timestamp-decode-date(adjusted-days);
  values(nsec-of(timestamp), seconds, minutes, hours, day, month, year,
         timestamp-day-of-week(timestamp, timezone: timezone, offset: offset),
         daylight-p, offset | offset*, abbreviation);
end method decode-timestamp;

define method timestamp-year (timestamp, #key timezone = *default-timezone*)
  // Returns the cardinal year upon which the timestamp falls.
  begin
    let (#rest _)
        = %timestamp-decode-date(begin
                                   let (#rest _)
                                       = %adjust-to-timezone(timestamp, timezone);
                                   _;
                                 end[1]);
    _;
  end[0];
end method timestamp-year;

define method timestamp-century (timestamp, #key timezone = *default-timezone*)
  // Returns the ordinal century upon which the timestamp falls.
  let year = timestamp-year(timestamp, timezone: timezone);
  let sign = if (year > 0) 1; elseif (year < 0) -1; else 0; end if;
  sign + sign * truncate/((abs(year) - 1), 100);
end method timestamp-century;

define method timestamp-millennium (timestamp, #key timezone = *default-timezone*)
  // Returns the ordinal millennium upon which the timestamp falls.
  let year = timestamp-year(timestamp, timezone: timezone);
  let sign = if (year > 0) 1; elseif (year < 0) -1; else 0; end if;
  sign + sign * truncate/((abs(year) - 1), 1000);
end method timestamp-millennium;

define method timestamp-decade (timestamp, #key timezone = *default-timezone*)
  // Returns the cardinal decade upon which the timestamp falls.
  truncate/(timestamp-year(timestamp, timezone: timezone), 10);
end method timestamp-decade;

define method timestamp-month (timestamp, #key timezone = *default-timezone*)
  // Returns the month upon which the timestamp falls.
  begin
    let (#rest _)
        = %timestamp-decode-date(begin
                                   let (#rest _)
                                       = %adjust-to-timezone(timestamp, timezone);
                                   _;
                                 end[1]);
    _;
  end[1];
end method timestamp-month;

define method timestamp-day (timestamp, #key timezone = *default-timezone*)
  // Returns the day of the month upon which the timestamp falls.
  begin
    let (#rest _)
        = %timestamp-decode-date(begin
                                   let (#rest _)
                                       = %adjust-to-timezone(timestamp, timezone);
                                   _;
                                 end[1]);
    _;
  end[2];
end method timestamp-day;

define method timestamp-hour (timestamp, #key timezone = *default-timezone*)
  begin
    let (#rest _)
        = %timestamp-decode-time(begin
                                   let (#rest _)
                                       = %adjust-to-timezone(timestamp, timezone);
                                   _;
                                 end[0]);
    _;
  end[0];
end method timestamp-hour;

define method timestamp-minute (timestamp, #key timezone = *default-timezone*)
  begin
    let (#rest _)
        = %timestamp-decode-time(begin
                                   let (#rest _)
                                       = %adjust-to-timezone(timestamp, timezone);
                                   _;
                                 end[0]);
    _;
  end[1];
end method timestamp-minute;

define method timestamp-second (timestamp, #key timezone = *default-timezone*)
  begin
    let (#rest _)
        = %timestamp-decode-time(begin
                                   let (#rest _)
                                       = %adjust-to-timezone(timestamp, timezone);
                                   _;
                                 end[0]);
    _;
  end[2];
end method timestamp-second;

define method timestamp-microsecond (timestamp)
  floor/(nsec-of(timestamp), 1000);
end method timestamp-microsecond;

define method timestamp-millisecond (timestamp)
  floor/(nsec-of(timestamp), 1000000);
end method timestamp-millisecond;

define method split-timestring (str, #rest args)
  apply(%split-timestring, as(<simple-string>, str), args);
end method split-timestring;

define method %split-timestring (time-string, #key start = 0, end = size(time-string),
                                 fail-on-error = #t, time-separator = ':',
                                 date-separator = '-', date-time-separator = 'T',
                                 allow-missing-elements = #t,
                                 allow-missing-date-part = allow-missing-elements,
                                 allow-missing-time-part = allow-missing-elements,
                                 allow-missing-timezone-part = allow-missing-time-part)
  // Based on http://www.ietf.org/rfc/rfc3339.txt including the function names used. Returns (values year month day hour minute second nsec offset-hour offset-minute). On parsing failure, signals INVALID-TIMESTRING if FAIL-ON-ERROR is NIL, otherwise returns NIL.
  block (return-from-%split-timestring)
    let year = #f;
    let month = #f;
    let day = #f;
    let hour = #f;
    let minute = #f;
    let second = #f;
    let nsec = #f;
    let offset-hour = #f;
    let offset-minute = #f;
    // LTD: Function MACROLET not yet implemented.
    macrolet((passert(expression(),
                      list(#"unless", expression,
                           list(#"parse-error",
                                list(#"quote",
                                     expression)))))(parse-integer-into(start-end(place,
                                                                                  &optional,
                                                                                  low-limit,
                                                                                  high-limit),
                                                                        begin
                                                                          let entry
                                                                              = generate-symbol(#"string"("ENTRY"));
                                                                          let value
                                                                              = generate-symbol(#"string"("VALUE"));
                                                                          let pos
                                                                              = generate-symbol(#"string"("POS"));
                                                                          let start
                                                                              = generate-symbol(#"string"("START"));
                                                                          let end
                                                                              = generate-symbol(#"string"("END"));
                                                                          list(#"let",
                                                                               list(list(entry,
                                                                                         start-end)),
                                                                               apply(list,
                                                                                     #"if",
                                                                                     entry,
                                                                                     list(#"let",
                                                                                          list(list(start,
                                                                                                    list(#"car",
                                                                                                         entry)),
                                                                                               list(end,
                                                                                                    list(#"cdr",
                                                                                                         entry))),
                                                                                          apply(list,
                                                                                                #"multiple-value-bind",
                                                                                                list(value,
                                                                                                     pos),
                                                                                                apply(list,
                                                                                                      #"parse-integer",
                                                                                                      #"time-string",
                                                                                                      start: start,
                                                                                                      end: end,
                                                                                                      #(#"junk-allowed",
                                                                                                        #"t")),
                                                                                                list(#"passert",
                                                                                                     list(#"=",
                                                                                                          pos,
                                                                                                          end)),
                                                                                                list(#"setf",
                                                                                                     place,
                                                                                                     value),
                                                                                                if (low-limit
                                                                                                     & high-limit)
                                                                                                  list(#"passert",
                                                                                                       list(#"<=",
                                                                                                            low-limit,
                                                                                                            place,
                                                                                                            high-limit));
                                                                                                else
                                                                                                  values();
                                                                                                end if,
                                                                                                #(#(#"values")))),
                                                                                     #(#(#"progn",
                                                                                         #(#"passert",
                                                                                           #"allow-missing-elements"),
                                                                                         #(#"values")))));
                                                                        end),
                                                     with-parts-and-count((start(end,
                                                                                 split-chars))(&body,
                                                                                               body),
                                                                          apply(list,
                                                                                #"multiple-value-bind",
                                                                                #(#"parts",
                                                                                  #"count"),
                                                                                list(#"split",
                                                                                     start,
                                                                                     end,
                                                                                     split-chars),
                                                                                body))),
             local method split (start, end, chars)
                     if (~ instance?(chars, <pair>)) chars := list(chars); end if;
                     let last-match = start;
                     let match-count
                          :: limited(<integer>, min: 0, max: 4611686018427387903)
                         = 0;
                     let result = make(<deque>);
                     block (return)
                       for (index :: <integer> from start, while index < end)
                         if (member?(time-string[index], chars, test: char-equal?))
                           push-last(result,
                                     begin
                                       let _
                                           = if (last-match < index)
                                               pair(last-match, index);
                                             else
                                               #f;
                                             end if;
                                       inc!(match-count);
                                       last-match := index + 1;
                                       _;
                                     end);
                         end if;
                       finally
                         return(if (zero?(index - last-match))
                                  result;
                                else
                                  let _
                                      = concatenate!(result,
                                                     list(pair(last-match, index)));
                                  inc!(match-count);
                                  _;
                                end if,
                                match-count);
                         result;
                       end for;
                     end block;
                   end method split,
                   method parse ()
                     with-parts-and-count(start(end, date-time-separator),
                                          if (count = 2)
                                            if (first(parts))
                                              full-date(first(parts));
                                            else
                                              passert(allow-missing-date-part);
                                            end if;
                                            if (second(parts))
                                              full-time(second(parts));
                                            else
                                              passert(allow-missing-time-part);
                                            end if;
                                            done();
                                          elseif (count = 1 & allow-missing-date-part
                                                   & cl-find(time-separator,
                                                             time-string,
                                                             start: head(first(parts)),
                                                             end: tail(first(parts))))
                                            full-time(first(parts));
                                            done();
                                          elseif (count = 1 & allow-missing-time-part
                                                   & cl-find(date-separator,
                                                             time-string,
                                                             start: head(first(parts)),
                                                             end: tail(first(parts))))
                                            full-date(first(parts));
                                            done();
                                          end if,
                                          parse-error(#f));
                   end method parse,
                   method full-date (start-end)
                     let parts
                         = split(head(start-end), tail(start-end), date-separator);
                     passert(%list-length=(3, parts));
                     date-fullyear(first(parts));
                     date-month(second(parts));
                     date-mday(third(parts));
                   end method full-date,
                   method date-fullyear (start-end)
                     parse-integer-into(start-end, year);
                   end method date-fullyear,
                   method date-month (start-end)
                     parse-integer-into(start-end, month, 1, 12);
                   end method date-month,
                   method date-mday (start-end)
                     parse-integer-into(start-end, day, 1, 31);
                   end method date-mday,
                   method full-time (start-end)
                     let start = head(start-end);
                     let end = tail(start-end);
                     with-parts-and-count(start(end, list('Z', '-', '+')),
                                          begin
                                            let zulup
                                                = cl-find('Z', time-string,
                                                          test: char-equal?,
                                                          start: start, end: end);
                                            let sign
                                                = if (~ zulup)
                                                    if (cl-find('+', time-string,
                                                                test: char-equal?,
                                                                start: start, end: end))
                                                      1;
                                                    else
                                                      -1;
                                                    end if;
                                                  end if;
                                            passert(1 <= count & count <= 2);
                                            if (~ (first(parts) == #f & ~ tail(parts)))
                                              //  not a single #\Z
                                              partial-time(first(parts));
                                            end if;
                                            if (zulup)
                                              begin
                                                offset-hour := 0;
                                                offset-minute := 0;
                                              end;
                                            end if;
                                            if (count = 1)
                                              passert(zulup
                                                       | allow-missing-timezone-part);
                                            else
                                              let entry = second(parts);
                                              let start = head(entry);
                                              let end = tail(entry);
                                              passert(zulup | ~ zero?((end - start)));
                                              if (~ zulup)
                                                time-offset(second(parts), sign);
                                              end if;
                                            end if;
                                          end);
                   end method full-time,
                   method partial-time (start-end)
                     with-parts-and-count((head(start-end))(tail(start-end),
                                                            time-separator),
                                          passert(count == 3), time-hour(first(parts)),
                                          time-minute(second(parts)),
                                          time-second(third(parts)));
                   end method partial-time,
                   method time-hour (start-end)
                     parse-integer-into(start-end, hour, 0, 23);
                   end method time-hour,
                   method time-minute (start-end)
                     parse-integer-into(start-end, minute, 0, 59);
                   end method time-minute,
                   method time-second (start-end)
                     with-parts-and-count((head(start-end))(tail(start-end),
                                                            #('.', ',')),
                                          passert(1 <= count & count <= 2),
                                          begin
                                            dynamic-bind (*read-eval* = #f)
                                              parse-integer-into(first(parts), second,
                                                                 0, 59);
                                              if (count > 1)
                                                let start = head(second(parts));
                                                let end = tail(second(parts));
                                                passert(end - start <= 9);
                                                let new-end
                                                    = find-key(copy-subsequence(time-string,
                                                                                start: start,
                                                                                end: end),
                                                               curry(\==, '0'));
                                                if (new-end)
                                                  end := min(new-end + 1);
                                                end if;
                                                nsec
                                                 := // LTD: Function PARSE-INTEGER not yet implemented.
                                                    parse-integer(time-string,
                                                                  start: start, end: end)
                                                     * #[1000000000, 100000000,
                                                         10000000, 1000000, 100000,
                                                         10000, 1000, 100, 10, 1][(end
                                                                                    - start)];
                                              else
                                                nsec := 0;
                                              end if;
                                            end dynamic-bind;
                                          end);
                   end method time-second,
                   method time-offset (start-end, sign)
                     with-parts-and-count((head(start-end))(tail(start-end),
                                                            time-separator),
                                          passert(allow-missing-timezone-part
                                                   & zero?(count)
                                                   | count = 1
                                                   | count = 2),
                                          if (count = 2)
                                            //  hh:mm offset
                                            parse-integer-into(first(parts),
                                                               offset-hour, 0, 23);
                                            parse-integer-into(second(parts),
                                                               offset-minute, 0, 59);
                                          elseif (tail(head(parts)) - head(head(parts))
                                                   = 4)
                                            //  hhmm offset
                                            parse-integer-into(pair(head(head(parts)),
                                                                    head(head(parts))
                                                                     + 2),
                                                               offset-hour, 0, 23);
                                            parse-integer-into(pair(head(head(parts))
                                                                     + 2,
                                                                    head(head(parts))
                                                                     + 4),
                                                               offset-minute, 0, 59);
                                          elseif (tail(head(parts)) - head(head(parts))
                                                   = 2)
                                            //  hh offset
                                            parse-integer-into(pair(head(head(parts)),
                                                                    head(head(parts))
                                                                     + 2),
                                                               offset-hour, 0, 23);
                                            offset-minute := 0;
                                          end if,
                                          begin
                                            offset-hour := offset-hour * sign;
                                            offset-minute := offset-minute * sign;
                                          end);
                   end method time-offset,
                   method parse-error (failure)
                     if (fail-on-error)
                       error(// LTD: Can't convert type specification.
                             #"invalid-timestring", timestring: time-string,
                             failure: failure);
                     else
                       return-from-%split-timestring(#f);
                     end if;
                   end method parse-error,
                   method done ()
                     return-from-%split-timestring(list(year, month, day, hour, minute,
                                                        second, nsec, offset-hour,
                                                        offset-minute));
                   end method done;
               parse());
  end block;
end method %split-timestring;

define method parse-rfc3339-timestring (timestring, #key fail-on-error = #t,
                                        allow-missing-time-part = #f)
  parse-timestring(timestring, fail-on-error: fail-on-error,
                   allow-missing-timezone-part: #f,
                   allow-missing-time-part: allow-missing-time-part,
                   allow-missing-date-part: #f);
end method parse-rfc3339-timestring;

define method parse-timestring (timestring, #key start, end, fail-on-error = #t,
                                time-separator = ':', date-separator = '-',
                                date-time-separator = 'T', allow-missing-elements = #t,
                                allow-missing-date-part = allow-missing-elements,
                                allow-missing-time-part = allow-missing-elements,
                                allow-missing-timezone-part = allow-missing-elements,
                                offset = 0)
  // Parse a timestring and return the corresponding TIMESTAMP.
  // See split-timestring for details. Unspecified fields in the
  // timestring are initialized to their lowest possible value,
  // and timezone offset is 0 (UTC) unless explicitly specified
  // in the input string.
  let parts
      = %split-timestring(as(<simple-string>, timestring), start: start | 0,
                          end: end | size(timestring), fail-on-error: fail-on-error,
                          time-separator: time-separator,
                          date-separator: date-separator,
                          date-time-separator: date-time-separator,
                          allow-missing-elements: allow-missing-elements,
                          allow-missing-date-part: allow-missing-date-part,
                          allow-missing-time-part: allow-missing-time-part,
                          allow-missing-timezone-part: allow-missing-timezone-part);
  if (parts)
    let g770
        = check-ds-list(parts, 9, 9,
                        #(#"year", #"month", #"day", #"hour", #"minute", #"second",
                          #"nsec", #"offset-hour", #"offset-minute"));
    let year = pop!(g770);
    let month = pop!(g770);
    let day = pop!(g770);
    let hour = pop!(g770);
    let minute = pop!(g770);
    let second = pop!(g770);
    let nsec = pop!(g770);
    let offset-hour = pop!(g770);
    let offset-minute = pop!(g770);
    encode-timestamp(nsec | 0, second | 0, minute | 0, hour | 0, day | 1, month | 3,
                     year | 2000,
                     offset: if (offset-hour)
                               offset-hour * 3600 + (offset-minute | 0) * 60;
                             else
                               offset;
                             end if);
  end if;
end method parse-timestring;

define method ordinalize (day)
  // Return an ordinal string representing the position
  // of DAY in a sequence (1st, 2nd, 3rd, 4th, etc).
  format(#f, "%d%S", day,
         if (11 <= day & day <= 13)
           "th";
         else
           select (mod(day, 10))
             1
                => "st";
             2
                => "nd";
             3
                => "rd";
             otherwise
                => "th";
           end select;
         end if);
end method ordinalize;

define method format-timestring (destination, timestamp,
                                 #key format = +iso-8601-format+,
                                 timezone = *default-timezone*)
  // Constructs a string representation of TIMESTAMP according
  // to FORMAT and returns it.
  // If destination is T, the string is written to *standard-output*.
  // If destination is a stream, the string is written to the stream.
  // 
  // FORMAT is a list containing one or more of strings, characters,
  // and keywords. Strings and characters are output literally,
  // while keywords are replaced by the values here:
  // 
  //   :YEAR              *year
  //   :MONTH             *numeric month
  //   :DAY               *day of month
  //   :HOUR              *hour
  //   :MIN               *minutes
  //   :SEC               *seconds
  //   :WEEKDAY           *numeric day of week starting from index 0, which means Sunday
  //   :MSEC              *milliseconds
  //   :USEC              *microseconds
  //   :NSEC              *nanoseconds
  //   :ISO-WEEK-YEAR     *year for ISO week date (can be different from regular calendar year)
  //   :ISO-WEEK-NUMBER   *ISO week number (i.e. 1 through 53)
  //   :ISO-WEEK-DAY      *ISO compatible weekday number (monday=1, sunday=7)
  //   :LONG-WEEKDAY      long form of weekday (e.g. Sunday, Monday)
  //   :SHORT-WEEKDAY     short form of weekday (e.g. Sun, Mon)
  //   :MINIMAL-WEEKDAY   minimal form of weekday (e.g. Su, Mo)
  //   :SHORT-YEAR        short form of year (last 2 digits, e.g. 41, 42 instead of 2041, 2042)
  //   :LONG-MONTH        long form of month (e.g. January, February)
  //   :SHORT-MONTH       short form of month (e.g. Jan, Feb)
  //   :HOUR12            *hour on a 12-hour clock
  //   :AMPM              am/pm marker in lowercase
  //   :GMT-OFFSET        the gmt-offset of the time, in +00:00 form
  //   :GMT-OFFSET-OR-Z   like :GMT-OFFSET, but is Z when UTC
  //   :GMT-OFFSET-HHMM   like :GMT-OFFSET, but in +0000 form
  //   :TIMEZONE          timezone abbrevation for the time
  // 
  // Elements marked by * can be placed in a list in the form
  //   (:keyword padding &optional (padchar #\0))
  // 
  // The string representation of the value will be padded with the padchar.
  // 
  // You can see examples in +ISO-8601-FORMAT+, +ASCTIME-FORMAT+, and +RFC-1123-FORMAT+.
  let result = %construct-timestring(timestamp, format, timezone);
  if (destination)
    write(if (#t == destination) *standard-output*; else destination; end if, result);
  end if;
  result;
end method format-timestring;

define method format-rfc1123-timestring (destination, timestamp,
                                         #key timezone = *default-timezone*)
  format-timestring(destination, timestamp, format: +rfc-1123-format+,
                    timezone: timezone);
end method format-rfc1123-timestring;

define method to-rfc1123-timestring (timestamp)
  format-rfc1123-timestring(#f, timestamp);
end method to-rfc1123-timestring;

define method format-rfc3339-timestring (destination, timestamp, #key omit-date-part,
                                         omit-time-part,
                                         omit-timezone-part = omit-time-part,
                                         use-zulu = #t, timezone = *default-timezone*)
  // Formats a timestring in the RFC 3339 format, a restricted form of the ISO-8601 timestring specification for Internet timestamps.
  let rfc3339-format
      = if (use-zulu & ~ omit-date-part & ~ omit-time-part & ~ omit-timezone-part)
          +rfc3339-format+;
        else
          //  micro optimization
          concatenate(if (~ omit-date-part)
                        #(#(#"year", 4), '-', #(#"month", 2), '-', #(#"day", 2));
                      end if,
                      if (~ (omit-date-part | omit-time-part)) #('T'); end if,
                      if (~ omit-time-part)
                        #(#(#"hour", 2), ':', #(#"min", 2), ':', #(#"sec", 2), '.',
                          #(#"usec", 6));
                      end if,
                      if (~ omit-timezone-part)
                        if (use-zulu)
                          #(#"gmt-offset-or-z");
                        else
                          #(#"gmt-offset");
                        end if;
                      end if);
        end if;
  format-timestring(destination, timestamp, format: rfc3339-format, timezone: timezone);
end method format-rfc3339-timestring;

define method to-rfc3339-timestring (timestamp)
  format-rfc3339-timestring(#f, timestamp);
end method to-rfc3339-timestring;

define method %read-timestring (stream, char)
  parse-timestring(begin
                     let str
                         = // LTD: Function MAKE-STRING-OUTPUT-STREAM not yet implemented.
                           make-string-output-stream();
                     block (nil)
                       begin
                         for (c = read-element(stream, nil) then read-element(stream,
                                                                              nil),
                              while c
                                     & (digit-char?(c)
                                         | member?(c,
                                                   #(':', 'T', 't', ':', '-', '+', 'Z',
                                                     '.'))))
                           print(c, str);
                         finally
                           if (c) unread-element(stream, c); end if;
                           #f;
                         end for;
                       end;
                     cleanup
                       close(str);
                     end block;
                     // LTD: Function GET-OUTPUT-STREAM-STRING not yet implemented.
                     get-output-stream-string(str);
                   end,
                   allow-missing-elements: #t);
end method %read-timestring;

define method %read-universal-time (stream, char, arg)
  universal-to-timestamp(// LTD: Function PARSE-INTEGER not yet implemented.
                         parse-integer(begin
                                         let str
                                             = // LTD: Function MAKE-STRING-OUTPUT-STREAM not yet implemented.
                                               make-string-output-stream();
                                         block (nil)
                                           begin
                                             for (c = read-element(stream,
                                                                   nil) then read-element(stream,
                                                                                          nil),
                                                  while c & digit-char?(c))
                                               print(c, str);
                                             finally
                                               if (c) unread-element(stream, c); end if;
                                               #f;
                                             end for;
                                           end;
                                         cleanup
                                           close(str);
                                         end block;
                                         // LTD: Function GET-OUTPUT-STREAM-STRING not yet implemented.
                                         get-output-stream-string(str);
                                       end));
end method %read-universal-time;

define method enable-read-macros ()
  // Enables the local-time reader macros for literal timestamps and universal time.
  // LTD: Function SET-MACRO-CHARACTER not yet implemented.
  set-macro-character('@', #"%read-timestring");
  set-dispatch-macro-character('#', '@', #"%read-universal-time");
  values();
end method enable-read-macros;

define variable *debug-timestamp* = #f;

define method print-object (object :: <timestamp>, stream)
  // Print the TIMESTAMP object using the standard reader notation
  if (*debug-timestamp*)
    begin
      let thunk
          = method ()
              format(stream, "%d/%d/%d", day-of(object), sec-of(object),
                     nsec-of(object));
            end method;
      %print-unreadable-object(object, stream,
                               logior(if (#t) 1; else 0; end if,
                                      if (#f) 2; else 0; end if),
                               thunk);
    end;
  else
    if (*print-escape*) write-element(stream, '@'); end if;
    format-rfc3339-timestring(stream, object);
  end if;
end method print-object;

define method astronomical-julian-date (timestamp)
  // Returns the astronomical julian date referred to by the timestamp.
  day-of(timestamp) - +astronomical-julian-date-offset+;
end method astronomical-julian-date;

define method modified-julian-date (timestamp)
  // Returns the modified julian date referred to by the timestamp.
  day-of(timestamp) - +modified-julian-date-offset+;
end method modified-julian-date;

// (declaim (notinline format-timestring))
"eof";

