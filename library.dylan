Module: dylan-user

define library time
  use collections,
    import: { table-extensions };
  use common-dylan;
  use c-ffi;
  use io,
    import: { format, format-out };
  export time;
end;

// Interface
define module time
  create
    <time-error>,

    // Time
    <time>,
    current-time,
    time-year,
    time-month,
    time-day-of-month,
    time-day-of-week,
    time-hour,
    time-minute,
    time-second,
    time-nanosecond,
    time-zone,
    $epoch,

    // Durations
    <duration>,
    duration-nanoseconds,
    $nanosecond,
    $microsecond,
    $millisecond,
    $second,
    $minute,
    $hour,

    // Days of the week
    <day>,
    day-full-name,
    day-short-name,
    $monday, $tuesday, $wednesday, $thursday, $friday, $saturday, $sunday,

    // Months
    <month>,
    month-number,
    month-full-name,
    month-short-name,
    month-days,
    $january, $february, $march, $april, $may, $june, $july,
    $august, $september, $october, $november, $december,

    // Conversions
    time-in-zone,
    time-in-utc,
    time-components,
    make-time,                  // from components
    parse-time,                 // TODO: $iso-8601-format etc?
    parse-duration,
    parse-day,                  // TODO: not sure about this
    format-time,
    format-duration,

    // Comparisons
    // duration < duration, duration = duration, time < time, time = time

    // Arithmetic
    // time + duration => time
    // duration + time => time
    // time - duration => time
    // duration - duration => duration

    // Zones
    <time-zone>,
    local-time-zone,
    zone-short-name,
    zone-full-name,
    zone-offset,
    zone-offset-string,
    $utc,
    $unknown-zone-name;
end;

// Implementation
define module %time
  use time;

  use c-ffi;
  use format,
    import: { format-to-string };
  use format-out;
  use common-dylan;
  use table-extensions,
    import: { <case-insensitive-string-table> };
end;
