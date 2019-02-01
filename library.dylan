Module: dylan-user

define library time
  use common-dylan;
  use generic-arithmetic;
  use big-integers;

  export time;
end;

// Interface
define module time
  create
    <time>, <zone>, <duration>, <weekday>, <month>, <time-error>,

    // Time
    current-time,
    time-year,
    time-month,
    time-day,
    time-hour,
    time-minute,
    time-second,
    time-nanosecond,
    time-weekday,
    time-zone,

    // Weekdays
    weekday-number,
    weekday-name,
    weekday-short-name,
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
    encode-time,
    decode-time,
    parse-time,                 // TODO: $iso-8601-format etc?
    format-time,
    parse-duration,
    format-duration,

    // as() vs parse-foo()...
    
    // as(<month>, int|string) ?
    // as(<weekday>, int|string) ?
    // as(<duration>, int|string) ?

    // $one-nanosecond, $one-second, $one-minute, etc?

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
    $utc;
end;

// Implementation
define module %time
  use time;
  // TODO: I'm going to develop this module using the slower
  //       big-integers arithmetic for all arithmetic operations,
  //       attempting to note any code that could really benefit from
  //       better performance, or whether the vast majority of
  //       arithmetic operations are not related to 64-bit nanosecond
  //       values. Can reassess the situation later.  See
  //       https://opendylan.org/documentation/library-reference/numbers.html
  //       #using-special-arithmetic-features   --cgay
  use generic-arithmetic-common-dylan;
end;
