Module: %time


define constant $microseconds/second :: <integer> = 1_000_000;
define constant $microseconds/minute :: <integer> = 60 * $microseconds/second;
define constant $microseconds/hour   :: <integer> = 60 * $microseconds/minute;
define constant $microseconds/day    :: <integer> = 24 * $microseconds/hour;

// A real (wall clock) time with microsecond precision, in UTC.
define sealed primary class <time> (<object>)
  // Number of microseconds since the Unix epoch, midnight 1970-01-01.  (Note that by
  // definition UTC includes leap seconds (well, at least until 2035) although the man
  // page for clock_gettime only implies that indirectly, under its description of
  // CLOCK_TAI.)  May be positive or negative.  With one sign bit and two Dylan tag bits
  // this gives a range of about +/- 73117 years. See compose-time and decompose-time for
  // how %microseconds is encoded.
  constant slot %microseconds :: <integer>, required-init-keyword: microseconds:;
end class;

define inline method to-utc-microseconds (t :: <time>) => (micros :: <integer>)
  t.%microseconds
end method;

define inline method to-utc-seconds (t :: <time>) => (seconds :: <integer>)
  floor/(t.%microseconds, 1_000_000)
end method;

define method print-object (time :: <time>, stream :: <stream>) => ()
  if (*print-escape?*)
    printing-object (time, stream)
      format-time(stream, $rfc3339, time);
    end;
  else
    format-time(stream, $rfc3339, time);
  end;
end method;

// The epoch represents 1970-01-01T00:00:00.0Z.
define constant $epoch :: <time> = make(<time>, microseconds: 0);

// TODO: For applications that find themselves allocating a lot of `<time>` objects
// (e.g., logging?), provide an API that allows them to be reinitialized from the current
// time or from another `<time>` without any additional allocation.

// Returns the current time provided by the system's realtime clock.
define sealed generic time-now () => (t :: <time>);

/* not yet, if at all

// Convert `t` to Unix time, the number of seconds since midnight 1970-01-01 EXCLUDING
// leap seconds.
define sealed generic to-unix-time (t :: <time>) => (seconds :: <integer>);

// Convert `t` to Unix time, the number of seconds since midnight 1970-01-01 INCLUDING
// leap seconds.
define sealed generic to-utc-time (t :: <time>) => (seconds :: <integer>);

*/

// Decompose `t` into its component parts for presentation. If `zone` is provided (it
// defaults to UTC) the returned values have had the appropriate zone offset applied.
define sealed generic decompose-time
    (t :: <time>, #key zone)
 => (year :: <integer>, month :: <month>, day-of-month :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     microsecond :: <integer>, day-of-week :: <day>);

// Create a time from the given components as interpreted for the given
// `zone`, which defaults to UTC.
define sealed generic compose-time
    (year :: <integer>, month :: <month>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     microsecond :: <integer>, #key zone)
 => (t :: <time>);

// Dispay `time` on `stream` in the given `format`. If `zone` is provided the time is
// displayed for that time zone.
define sealed generic format-time
    (stream :: <stream>, format :: <object>, time :: <time>, #key zone) => ();

define sealed generic parse-time
    (time :: <string>, #key format, zone) => (time :: <time>);

// TODO:
// define sealed generic round-time (t :: <time>, d :: <duration>) => (t :: <time>);
// define sealed generic truncate-time (t :: <time>, d :: <duration>) => (t :: <time>);


// --- <duration> and its generic functions ---

// <duration> represents a time interval in nanoseconds. They may be positive or
// negative. On 64 bit systems, with 2 Dylan tag bits, and 1 sign bit, this gives a
// maximum duration of just over 73 years.
define class <duration> (<object>)
  constant slot duration-nanoseconds :: <integer> = 0,
    init-keyword: nanoseconds:;
end class;

define sealed generic duration-nanoseconds
    (d :: <duration>) => (nanoseconds :: <integer>);

// May signal <time-error>.
define sealed generic parse-duration
    (string :: <string>, #key start, end: _end) => (duration :: <duration>, end-pos :: <integer>);

define sealed generic format-duration
    (stream :: <stream>, duration :: <duration>, #key long?) => ();

define method print-object
    (d :: <duration>, stream :: <stream>) => ()
  if (*print-escape?*)
    printing-object (d, stream)
      format-duration(stream, d);
    end;
  else
    format-duration(stream, d);
  end;
end method;

define constant $nanosecond  :: <duration> = make(<duration>, nanoseconds: 1);
define constant $microsecond :: <duration> = 1000 * $nanosecond;
define constant $millisecond :: <duration> = 1000 * $microsecond;
define constant $second      :: <duration> = 1000 * $millisecond;
define constant $minute      :: <duration> = 60 * $second;
define constant $hour        :: <duration> = 60 * $minute;
define constant $day         :: <duration> = 24 * $hour;
define constant $week        :: <duration> = 7 * $day;


// --- Arithmetic and comparisons ---

// Since zone is used purely for display purposes, it is ignored during
// arithmetic and comparison operations.

// TODO: <instant> (i.e., monotonic clock times) +/- <duration>

define sealed domain \+ (<duration>, <duration>);
define sealed domain \- (<duration>, <duration>);
define sealed domain \* (<duration>, <real>);
define sealed domain \* (<real>, <duration>);
define sealed domain \/ (<duration>, <real>);

define sealed domain \= (<time>, <time>);
define sealed domain \= (<duration>, <duration>);
define sealed domain \< (<time>, <time>);
define sealed domain \< (<duration>, <duration>);

// =

define method \= (t1 :: <time>, t2 :: <time>) => (_ :: <boolean>)
  t1.%microseconds == t2.%microseconds
end method;

define method \= (d1 :: <duration>, d2 :: <duration>) => (_ :: <boolean>)
  d1.duration-nanoseconds == d2.duration-nanoseconds
end method;

define method \< (t1 :: <time>, t2 :: <time>) => (_ :: <boolean>)
  let m1 :: <integer> = t1.%microseconds;
  let m2 :: <integer> = t2.%microseconds;
  m1 < m2
/*
  // Avoid the division necessary to extract days and micros, which is only necessary
  // when both m1 and m2 are negative (which is rare), due to days extending backward in
  // time (negative) and then microseconds within that day extending forward in time.
  if (m1 < 0)
    m2 >= 0
      | begin // both negative
          todo
          let (day1, micro1) = floor/(m1, $microseconds/day);
          let (day2, micro2) = floor/(m2, $microseconds/day);
          day1 < day2 | (day1 == day2 & micro1 < micro2)
        end
  elseif (m2 < 0)
    #f                          // m1 >= 0, m2 < 0
  else
    m1 < m2                     // both positive
  end
*/
end method;

define method \< (d1 :: <duration>, d2 :: <duration>) => (_ :: <boolean>)
  d1.duration-nanoseconds < d2.duration-nanoseconds
end method;


// +

define method \+ (d1 :: <duration>, d2 :: <duration>) => (d :: <duration>)
  make(<duration>, nanoseconds: d1.duration-nanoseconds + d2.duration-nanoseconds)
end method;

// -

define method \- (d1 :: <duration>, d2 :: <duration>) => (d :: <duration>)
  make(<duration>, nanoseconds: d1.duration-nanoseconds - d2.duration-nanoseconds)
end method;

// This is for convenience only; don't use it try try and do date math because
// `<duration>` only represents idealized time units.


// *

define method \* (d :: <duration>, r :: <real>) => (d :: <duration>)
  make(<duration>, nanoseconds: as(<integer>, d.duration-nanoseconds * r))
end method;

define method \* (r :: <real>, d :: <duration>) => (d :: <duration>)
  d * r
end method;

// /

define method \/ (d :: <duration>, r :: <real>) => (d :: <duration>)
  make(<duration>, nanoseconds: floor/(d.duration-nanoseconds, r))
end method;


// --- Unix time with and without leap seconds ---


/* not yet, if at all

define inline method to-unix-time (t :: <time>) => (seconds :: <integer>)
  floor/(t.%microseconds, $microseconds/second)
end method;

// A sequence of Unix times at which leap seconds have been inserted, as defined here:
// https://www.nist.gov/pml/time-and-frequency-division/time-realization/leap-seconds
// Each element is a Unix time in seconds, itself excluding any leap seconds.
// The sequence of events is: 23h 59m 59s -> 23h 59m 60s -> 00h 00m 00s.
define constant $leap-second-insertion-times
  = begin
      local method ut (jd) => (ut :: <integer>)
              let day = 0; // TODO: julian-to-civil(jd);
              (day + 1) * 24 * 60 * 60 - 1 // 23:59:59 on day
            end;
      // newest to oldest
      vector(ut(57753), // 2016-12-31
             ut(57203), // 2015-06-30
             ut(56108), // 2012-06-30
             ut(54831), // 2008-12-31
             ut(53735), // 2005-12-31
             ut(51178), // 1998-12-31
             ut(50629), // 1997-06-30
             ut(50082), // 1995-12-31
             ut(49533), // 1994-06-30
             ut(49168), // 1993-06-30
             ut(48803), // 1992-06-30
             ut(48256), // 1990-12-31
             ut(47891), // 1989-12-31
             ut(47160), // 1987-12-31
             ut(46246), // 1985-06-30
             ut(45515), // 1983-06-30
             ut(45150), // 1982-06-30
             ut(44785), // 1981-06-30
             ut(44238), // 1979-12-31
             ut(43873), // 1978-12-31
             ut(43508), // 1977-12-31
             ut(43143), // 1976-12-31
             ut(42777), // 1975-12-31
             ut(42412), // 1974-12-31
             ut(42047), // 1973-12-31
             ut(41682), // 1972-12-31
             ut(41498)) // 1972-06-30
    end;

define method to-utc-time (t :: <time>) => (seconds :: <integer>)
  let ut = t.to-unix-time;
  // Use the dumbest possible way to figure out the number of leap seconds to add.
  let length = $leap-second-insertion-times.size;
  iterate loop (i = 0)
    if (i >= length)
      ut
    elseif (ut > $leap-second-insertion-times[i])
      ut + length - i           // assumes only positive leap seconds
    else
      loop(i + 1)
    end
  end
end method;
*/

// --- Building/decomposing times ---

// The calendrical code here directly follows
// http://howardhinnant.github.io/date_algorithms.html, which you will need to read to
// understand the code. One oddity is the (completely internal to the algorithms) use of
// March 1 as the beginning of the year, which gives the nice property that leap days
// come at the end of the year and therefore need not affect various other
// calculations. A 400 year "era" is useful since the Gregorian calendar repeats itself
// every 400 years.

define constant $days/era = 146097;   // days per 400-year era
define constant $epoch-days = 719468; // days between 0000-03-01 and 1970-01-01

define function days-to-weekday
    (days :: <integer>) => (weekday :: <day>)
  select (modulo(days + 4, 7))
    0 => $sunday;
    1 => $monday;
    2 => $tuesday;
    3 => $wednesday;
    4 => $thursday;
    5 => $friday;
    6 => $saturday;
  end
end function;

// Given year, month, and day, return the number of days since Gregorian 1970-01-01.
// Negative values indicate days prior to 1970-01-01.
define function civil-to-days
    (y :: <integer>, m :: <integer>, d :: <integer>) => (days :: <integer>)
  let y = y - if (m <= 2) 1 else 0 end; // year begins March 1 for leap year convenience
  let era = floor/(if (y >= 0) y else y - 399 end, 400);
  let yoe = y - era * 400;                                         // [0, 399]
  // TODO: vector lookup probably faster: v[m] + d - 1
  // See "month, m', days after m'-01" table in blog.
  let doy = floor/(153 * iff(m > 2, m - 3, m + 9) + 2, 5) + d - 1; // [0, 365]
  let doe = yoe * 365 + floor/(yoe, 4) - floor/(yoe, 100) + doy;   // [0, 146096]
  era * $days/era + doe - $epoch-days
end function;

// Given a number of days relative to the epoch, either positive or negative, returns the
// year, month, and day in the Gregorian calendar.
define function days-to-civil
    (days :: <integer>) => (year :: <integer>, month :: <integer>, day :: <integer>)
  let z = days + $epoch-days;
  // era = "which 400-year span is `days` in?"
  let era = floor/(if (z >= 0) z else z - 146096 end,
                   $days/era);
  let doe = z - era * $days/era;
  let yoe = floor/(doe - floor/(doe, 1460) - floor/(doe, 36524) - floor/(doe, 146096),
                   365);
  let y = yoe + era * 400;
  // const unsigned doy = doe - (365*yoe + yoe/4 - yoe/100);
  let doy = doe - (yoe * 365 + floor/(yoe, 4) - floor/(yoe, 100));
  let mp = floor/(doy * 5 + 2, 153);
  let d = doy - floor/(mp * 153 + 2, 5) + 1;
  let m = mp + if (mp < 10) 3 else -9 end;
  values(y + if (m <= 2) 1 else 0 end, m, d)
end function;

define method compose-time
    (year :: <integer>, month :: <month>, day :: <integer>, hour :: <integer>,
     minute :: <integer>, second :: <integer>, microsecond :: <integer>,
     #key zone :: <zone> = $utc)
 => (t :: <time>)
  let days = civil-to-days(year, month-number(month), day);
  let utc-microseconds = (days * $microseconds/day
                            + hour * $microseconds/hour
                            + minute * $microseconds/minute
                            + second * $microseconds/second
                            + microsecond);
  let offset = %zone-offset-seconds(zone, utc-microseconds);
  let micros = utc-microseconds - offset * $microseconds/second; // UTC -> zone
  make(<time>, microseconds: micros)
end method;

define method decompose-time
    (t :: <time>, #key zone :: <zone> = $utc)
 => (year :: <integer>, month :: <month>, day :: <integer>, hour :: <integer>,
     minute :: <integer>, second :: <integer>, microsecond :: <integer>,
     day-of-week :: <day>)
  let offset-micros = zone-offset-seconds(zone, time: t) * $microseconds/second;
  let micros = t.%microseconds + offset-micros;
  let (days, micros) = floor/(micros, $microseconds/day);
  let (year, month, day) = days-to-civil(days);
  let month = as(<month>, month);
  let (hour, rem)   = floor/(micros, $microseconds/hour);
  let (minute, rem) = floor/(rem, $microseconds/minute);
  let (second, microsecond) = floor/(rem, $microseconds/second);
  let day-of-week = days-to-weekday(days);
  values(year, month, day, hour, minute, second, microsecond, day-of-week)
end method;


// --- Current time ---

// Returns the current time provided by the system's realtime clock as the number of
// microseconds since 1970-01-01 00:00Z.
define method time-now-microseconds () => (microseconds :: <integer>)
  let spec = make(<timespec*>);
  if (clock-gettime(get-clock-realtime(), spec) ~== 0)
    // TODO: return the value of errno and a better error message.
    time-error("could not get clock value from system");
  end;
  spec.timespec-seconds * $microseconds/second
    + floor/(spec.timespec-nanoseconds, 1_000)
end method;

define method time-now () => (t :: <time>)
  make(<time>, microseconds: time-now-microseconds())
end method;

// --- Days of the week ---

// TODO: do we need day-number => 1..7? 0..6? (no standard)
define sealed generic day-long-name (d :: <day>) => (name :: <string>);
define sealed generic day-short-name (d :: <day>) => (name :: <string>);
define sealed generic parse-day (name :: <string>) => (day :: <day>);

define sealed class <day> (<object>)
  constant slot day-long-name :: <string>, required-init-keyword: long-name:;
  constant slot day-short-name :: <string>, required-init-keyword: short-name:;
end class;

define method print-object (day :: <day>, stream :: <stream>) => ()
  if (*print-escape?*)
    printing-object (day, stream)
      print(day.day-long-name, stream);
    end;
  else
    print(day.day-long-name, stream);
  end;
end method;

define constant $monday    :: <day> = make(<day>, short-name: "Mon", long-name: "Monday");
define constant $tuesday   :: <day> = make(<day>, short-name: "Tue", long-name: "Tuesday");
define constant $wednesday :: <day> = make(<day>, short-name: "Wed", long-name: "Wednesday");
define constant $thursday  :: <day> = make(<day>, short-name: "Thu", long-name: "Thursday");
define constant $friday    :: <day> = make(<day>, short-name: "Fri", long-name: "Friday");
define constant $saturday  :: <day> = make(<day>, short-name: "Sat", long-name: "Saturday");
define constant $sunday    :: <day> = make(<day>, short-name: "Sun", long-name: "Sunday");

define method parse-day (name :: <string>) => (d :: <day>)
  element($short-name-to-day, name, default: #f)
    | element($name-to-day, name, default: #f)
    | time-error("%= is not a valid day name", name)
end;

define table $name-to-day :: <istring-table> = {
  $monday.day-long-name    => $monday,
  $tuesday.day-long-name   => $tuesday,
  $wednesday.day-long-name => $wednesday,
  $thursday.day-long-name  => $thursday,
  $friday.day-long-name    => $friday,
  $saturday.day-long-name  => $saturday,
  $sunday.day-long-name    => $sunday
};

define table $short-name-to-day :: <istring-table> = {
  $monday.day-short-name    => $monday,
  $tuesday.day-short-name   => $tuesday,
  $wednesday.day-short-name => $wednesday,
  $thursday.day-short-name  => $thursday,
  $friday.day-short-name    => $friday,
  $saturday.day-short-name  => $saturday,
  $sunday.day-short-name    => $sunday
};


// --- Months ---

// month-number returns the 1-based month number for the given month.
// January = 1, February = 2, etc.
define sealed generic month-number (m :: <month>) => (n :: <integer>);

// month-long-name returns the long name of the month. "January", "February", etc.
define sealed generic month-long-name (m :: <month>) => (n :: <string>);

// month-short-name returns the 3-letter month name with an initial
// capital letter. "Jan", "Feb", etc.
define sealed generic month-short-name (m :: <month>) => (n :: <string>);

// month-days returns the standard (non-leap year) days in the month.
// January = 31, February = 28, etc.
define sealed generic month-days (m :: <month>) => (n :: <integer>);

define sealed class <month> (<object>)
  constant slot month-number :: <integer>,    required-init-keyword: number:;
  constant slot month-long-name :: <string>,  required-init-keyword: long-name:;
  constant slot month-short-name :: <string>, required-init-keyword: short-name:;
  constant slot month-days :: <integer>,      required-init-keyword: days:;
end class;

define method print-object (month :: <month>, stream :: <stream>) => ()
  if (*print-escape?*)
    printing-object(month, stream, identity?: #f)
      print(month.month-long-name, stream);
    end;
  else
    print(month.month-long-name, stream);
  end;
end method;

define constant $january :: <month>
  = make(<month>, number:  1, short-name: "Jan", days: 31, long-name: "January");
define constant $february :: <month>
  = make(<month>, number:  2, short-name: "Feb", days: 28, long-name: "February");
define constant $march :: <month>
  = make(<month>, number:  3, short-name: "Mar", days: 31, long-name: "March");
define constant $april :: <month>
  = make(<month>, number:  4, short-name: "Apr", days: 30, long-name: "April");
define constant $may :: <month>
  = make(<month>, number:  5, short-name: "May", days: 31, long-name: "May");
define constant $june :: <month>
  = make(<month>, number:  6, short-name: "Jun", days: 30, long-name: "June");
define constant $july :: <month>
  = make(<month>, number:  7, short-name: "Jul", days: 31, long-name: "July");
define constant $august :: <month>
  = make(<month>, number:  8, short-name: "Aug", days: 31, long-name: "August");
define constant $september :: <month>
  = make(<month>, number:  9, short-name: "Sep", days: 30, long-name: "September");
define constant $october :: <month>
  = make(<month>, number: 10, short-name: "Oct", days: 31, long-name: "October");
define constant $november :: <month>
  = make(<month>, number: 11, short-name: "Nov", days: 30, long-name: "November");
define constant $december :: <month>
  = make(<month>, number: 12, short-name: "Dec", days: 31, long-name: "December");
define constant $months
  = vector($january, $february, $march, $april, $may, $june, $july,
           $august, $september, $october, $november, $december);

define method as (class == <month>, n :: <integer>) => (m :: <month>)
  if (n < 1 | n > 12)
    time-error("invalid month number %d outside the range 1..12", n);
  end;
  $months[n - 1]
end;

define method as (class == <month>, name :: <string>) => (m :: <month>)
  if (size(name) == 3)
    element($short-name-to-month, name, default: #f)
  else
    element($name-to-month, name, default: #f)
  end
  | time-error("%= does not designate a valid month", name)
end;

define table $name-to-month :: <string-table> = {
  $january.month-long-name   => $january,
  $february.month-long-name  => $february,
  $march.month-long-name     => $march,
  $april.month-long-name     => $april,
  $may.month-long-name       => $may,
  $june.month-long-name      => $june,
  $july.month-long-name      => $july,
  $august.month-long-name    => $august,
  $september.month-long-name => $september,
  $october.month-long-name   => $october,
  $november.month-long-name  => $november,
  $december.month-long-name  => $december
};

define table $short-name-to-month :: <string-table> = {
  $january.month-short-name   => $january,
  $february.month-short-name  => $february,
  $march.month-short-name     => $march,
  $april.month-short-name     => $april,
  $may.month-short-name       => $may,
  $june.month-short-name      => $june,
  $july.month-short-name      => $july,
  $august.month-short-name    => $august,
  $september.month-short-name => $september,
  $october.month-short-name   => $october,
  $november.month-short-name  => $november,
  $december.month-short-name  => $december
};

define constant $minimum-time :: <time> = make(<time>, microseconds: $minimum-integer);
define constant $maximum-time :: <time> = make(<time>, microseconds: $maximum-integer);
