Module: dylan-user

define library time
  use collections,
    import: { table-extensions };
  use common-dylan;
  use c-ffi;
  use io,
    import: { format, format-out, print, pprint, standard-io, streams };
  use strings;
  use system,
    import: { file-system, locators, threads };
  export
    time,
    %time;                // for unit tests only! depend on this at your peril!
end library time;

// Interface
define module time
  create
    <time-error>,

    // Time
    <time>,
    time-now,
    time-components,            // returns the following nine values, in order
      time-year,
      time-month,
      time-day-of-month,
      time-hour,
      time-minute,
      time-second,
      time-nanosecond,
      time-zone,
      time-day-of-week,
    $epoch,
    
    format-time,
    $rfc3339,                   // minimum digits for fractional seconds
    $rfc3339-milliseconds,      // 3 digit fractional second
    $rfc3339-microseconds,      // 6 digit fractional second

    // Durations
    <duration>,
    duration-nanoseconds,
    $nanosecond, $microsecond, $millisecond, $second, $minute, $hour, $day, $week,
    format-duration,

    // Days of the week
    <day>,
    day-long-name,
    day-short-name,
    $monday, $tuesday, $wednesday, $thursday, $friday, $saturday, $sunday,

    // Months
    <month>,
    month-number,
    month-long-name,
    month-short-name,
    month-days,
    $january, $february, $march, $april, $may, $june, $july,
    $august, $september, $october, $november, $december,

    // Conversions
    make-time,                  // from its components
    time-in-zone,
    time-components,
    parse-time,                 // TODO: $iso-8601-format etc?
    parse-duration,
    parse-day,                  // TODO: not sure about this
    format-time,
    format-duration,
    <time-format>,
    // as(<month>, integer)
    // as(<month>, string)

    // Comparisons
    // duration < duration, duration = duration, time < time, time = time

    // Arithmetic
    // time + duration => time
    // duration + time => time
    // time - duration => time
    // duration - duration => duration

    // Zones
    <zone>,
    zone-abbreviation,
    zone-daylight-savings?,
    zone-name,
    zone-offset,
    zone-offset-string,
    find-zone,
    local-time-zone,
    $utc;
end module time;

// Implementation
define module %time
  use time;

  use c-ffi;
  use common-dylan;
  use file-system,
    import: { <file-locator>, do-directory, file-exists?, locator-name, resolve-locator,
              with-open-file };
  use format,
    import: { format, format-to-string };
  use format-out;
  use locators,
    import: { <directory-locator>, <file-locator>, locator-name, resolve-locator };
  use print,
    import: { print, print-object, printing-object, *print-escape?* };
  use standard-io,
    import: { *standard-output* };
  use streams,
    import: { <byte>, <stream>, read, write, write-element };
  use strings,
    import: { decimal-digit?, string-equal-ic?, whitespace? };
  use table-extensions,
    rename: { <case-insensitive-string-table> => <istring-table> };
  use threads,
    import: { <lock>, with-lock };

  // Exports for tests only.
  export
    %days,
    %nanoseconds,
    <naive-zone>,
    <aware-zone>,
    <subzone>,
    load-tzif-file;
end module %time;
