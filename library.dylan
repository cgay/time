Module: dylan-user

define library time
  use common-dylan;
  use generic-arithmetic;
  use big-integers;
end;

define module time
  // TODO: I'm going to develop this module using the slower
  //       big-integers arithmetic for all arithmetic operations,
  //       attempting to note any code that could really benefit from
  //       better performance, or whether the vast majority of
  //       arithmetic operations are not related 64-bit nanosecond
  //       values. Can reassess the situation later.  See
  //       https://opendylan.org/documentation/library-reference/numbers.html
  //       #using-special-arithmetic-features   --cgay
  use generic-arithmetic-common-dylan;
  export
    <time>, <date>, <timezone>, <day>, <month>,

    // Basic time and date accessors
    year, month, day, hour, minute, second, nanosecond, weekday,
    zone, zone-setter,

    // Weekday accessors
    weekday-number, weekday-name, weekday-short-name,
    $monday, $tuesday, $wednesday, $thursday, $friday, $saturday, $sunday,

    // Month accessors
    month-number, month-name, month-short-name, month-days,
    $january, $february, $march, $april, $may, $june, $july,
    $august, $september, $october, $november, $december,

    // Encoding / decoding
    encode-time, decode-time,
    encode-date, decode-date,
    parse-time, format-time,

    // Current time and date
    now, today,

    // Comparisons
    // < is defined for two times or two durations.
    // = is defined for two times or two durations.

    // Arithmetic
    // + is defined for time X duration (either order)
    // - is defined for time X duration

end;
