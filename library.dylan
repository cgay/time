Module: dylan-user

// TODO: platform-specific libraries

define library time
  use big-integers;
  use collections,
    import: { table-extensions };
  use common-dylan;
  use c-ffi;
  use generic-arithmetic;
  use io,
    import: { format };
  export time;
end;

// Interface
define module time
  create
    <time>, <time-zone>, <duration>, <day>, <month>, <time-error>,

    // Time
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

    // Durations
    $nanosecond,
    $microsecond,
    $millisecond,
    $second,
    $minute,
    $hour,

    // Days of the week
    day-number,
    day-name,
    day-short-name,
    $monday, $tuesday, $wednesday, $thursday, $friday, $saturday, $sunday,

    // Months
    month-number,
    month-name,
    month-short-name,
    month-days,
    $january, $february, $march, $april, $may, $june, $july,
    $august, $september, $october, $november, $december,

    // Conversions
    time-in-zone,
    time-in-utc,
    time-components,
    truncate-time,
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
    local-time-zone,
    zone-name,
    zone-offset,
    zone-offset-string,
    $utc;
end;

// Implementation
define module %time
  use time;

  use c-ffi;
  use format,
    import: { format-to-string };
  // TODO: I'm going to develop this module using the slower
  //       big-integers arithmetic for all arithmetic operations,
  //       attempting to note any code that could really benefit from
  //       better performance, or whether the vast majority of
  //       arithmetic operations are not related to 64-bit nanosecond
  //       values. Can reassess the situation later.  See
  //       https://opendylan.org/documentation/library-reference/numbers.html
  //       #using-special-arithmetic-features   --cgay
  use generic-arithmetic-common-dylan;
  use table-extensions,
    import: { <case-insensitive-string-table> };
end;
