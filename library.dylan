Module: dylan-user

define library time
  use collections,
    import: { table-extensions };
  use common-dylan;
  use c-ffi;
  use io,
    import: { format, format-out, print, pprint, standard-io, streams };
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
    time-components,            // returns the following seven values
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
    
    print-time,
    format-time,
    $rfc3339,
    $rfc3339-precise,

    // Durations
    <duration>,
    duration-nanoseconds,
    $nanosecond,
    $microsecond,
    $millisecond,
    $second,
    $minute,
    $hour,
    print-duration,
    format-duration,
    $duration-heuristic,
    $duration-brief,
    $duration-long,

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
    time-in-zone,
    time-in-utc,
    make-time,                  // from components
    parse-time,                 // TODO: $iso-8601-format etc?
    parse-duration,
    parse-day,                  // TODO: not sure about this
    format-time,
    format-duration,
    <time-format>,

    // Comparisons
    // duration < duration, duration = duration, time < time, time = time

    // Arithmetic
    // time + duration => time
    // duration + time => time
    // time - duration => time
    // duration - duration => duration

    // Zones
    <zone>,
    local-time-zone,
    zone-short-name,
    zone-long-name,
    zone-offset,
    zone-offset-string,
    $utc;
end module time;

// Implementation
define module %time
  use time;

  use c-ffi;
  use common-dylan;
  use format,
    import: { format, format-to-string };
  use format-out;
  use print,
    import: { print-object };
  use pprint,
    import: { printing-logical-block };
  use standard-io,
    import: { *standard-output* };
  use streams,
    import: { <stream>, write };
  use table-extensions,
    rename: { <case-insensitive-string-table> => <istring-table> };

  // Exports for tests only.
  export
    %seconds,
    %nanoseconds;
end module %time;
