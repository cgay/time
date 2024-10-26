Module: dylan-user

define library time
  use big-integers;
  use collections,
    import: { table-extensions };
  use common-dylan;
  use c-ffi;
  use generic-arithmetic;
  use io,
    import: { format, format-out, print, pprint, standard-io, streams };
  use strings;
  use system,
    import: { file-system, locators, operating-system, threads };
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
    time-components,            // => year, month, day, hour, minute, second, nanosecond
    $epoch,
    $minimum-time,
    $maximum-time,

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
    compose-time,               // make a <time> from its components
    time-components,            // break a <time> into its components
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
    zone-offset-seconds,
    zone-offset-string,
    find-zone,
    local-time-zone,
    $utc,

    // For tzifdump
    dump-zone,
    load-tzif-file;
end module time;

// Implementation
define module %time
  use time;

  use c-ffi;
  use common-dylan;
  use file-system,
    import: { <file-locator>, do-directory, file-exists?, link-target,
              with-open-file };
  use format,
    import: { format, format-to-string };
  use format-out;
  use generic-arithmetic,
    prefix: "ga/";
  use locators;
  use operating-system,
    prefix: "os/";
  use print,
    import: { print, print-object, printing-object, *print-escape?* };
  use standard-io,
    import: { *standard-output* };
  use streams,
    import: { <byte>, <stream>, read-to-end, write, write-element };
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
    subzones,
    subzone-start-time,
    $min-offset-seconds,
    $max-offset-seconds,

    // tzif
    <tzif>,
    bytes-to-int32,
    bytes-to-int64,
    load-zone,
    load-all-zones,
    tzif-version,
    tzif-end-of-v1-data,
    tzif-end-of-v2-data,
    tzif-is-utc-count,
    tzif-is-std-count,
    tzif-leap-count,
    tzif-time-count,
    tzif-type-count,
    tzif-char-count;
end module %time;
