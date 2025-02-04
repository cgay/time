Module: %time
Synopsis: Time and duration implementations (because they're somewhat intertwined)

// --- <time> and its generic functions ---


// A <time> represents an instant in UTC time, to nanosecond precision.
define sealed primary class <time> (<object>)
  // Number of days since the epoch. May be positive or negative.
  constant slot %days :: <integer>, required-init-keyword: days:;

  // Number of nanoseconds within the day. An non-negative integer.
  constant slot %nanoseconds :: <integer>, required-init-keyword: nanoseconds:;
end class;

define method print-object (time :: <time>, stream :: <stream>) => ()
  if (*print-escape?*)
    printing-object (time, stream)
      format(stream, "%dd %dns UTC", time.%days, time.%nanoseconds);
    end;
  else
    format-time(stream, $rfc3339, time);
  end;
end method;

define constant $epoch :: <time>
  = make(<time>, days: 0, nanoseconds: 0);

// TODO: as-unix-time (not sure of name yet)

// TODO: For applications that find themselves allocating a lot of `<time>` objects
// (e.g., logging?), provide an API that allows them to be reinitialized from the current
// time or from another `<time>` without any additional allocation.

// Returns the current time provided by the system's realtime clock.
define sealed generic time-now () => (t :: <time>);

// Decompose `t` into its component parts for presentation. If `zone` is
// provided (it defaults to UTC) the returned values have had the appropriate
// zone offset applied.
define sealed generic time-components
    (t :: <time>, #key zone)
 => (year :: <integer>, month :: <month>, day-of-month :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, day-of-week :: <day>);

// Create a time from the given components as interpreted for the given
// `zone`, which defaults to UTC.
define sealed generic compose-time
    (year :: <integer>, month :: <month>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, #key zone)
 => (t :: <time>);

// The zone in `time` may be overridden by providing the `zone` argument.
define sealed generic format-time
    (stream :: <stream>, format :: <object>, time :: <time>, #key zone) => ();

define sealed generic parse-time
    (time :: <string>, #key format, zone) => (time :: <time>);

// TODO:
// define sealed generic round-time (t :: <time>, d :: <duration>) => (t :: <time>);
// define sealed generic truncate-time (t :: <time>, d :: <duration>) => (t :: <time>);


// --- <duration> and its generic functions ---

// <duration> represents the difference between two times, in nanoseconds. They
// may be positive or negative. On 64 bit systems, with 2 tag bits, and 1 sign
// bit, this gives a maximum duration of just over 73 years.
define class <duration> (<object>)
  constant slot duration-nanoseconds :: <integer> = 0,
    init-keyword: nanoseconds:;
end;

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

define constant $nanosecond :: <duration>  = make(<duration>, nanoseconds: 1);
define constant $microsecond :: <duration> = make(<duration>, nanoseconds: 1_000);
define constant $millisecond :: <duration> = make(<duration>, nanoseconds: 1_000_000);
define constant $second :: <duration> = make(<duration>, nanoseconds: 1_000_000_000);
define constant $minute :: <duration> = make(<duration>, nanoseconds: 1_000_000_000 * 60);
define constant $hour :: <duration>   = make(<duration>, nanoseconds: 1_000_000_000 * 3600);
define constant $day :: <duration>    = make(<duration>, nanoseconds: 1_000_000_000 * 3600 * 24);
define constant $week :: <duration>   = make(<duration>, nanoseconds: 1_000_000_000 * 3600 * 24 * 7);


// --- Arithmetic and comparisons ---

// Since zone is used purely for display purposes, it is ignored during
// arithmetic and comparison operations.

define sealed domain \+ (<duration>, <duration>);
define sealed domain \+ (<time>, <duration>);
define sealed domain \+ (<duration>, <time>);
define sealed domain \- (<time>, <time>);
define sealed domain \- (<time>, <duration>);
define sealed domain \- (<duration>, <duration>);
// TODO: <duration> - <integer> => ???
define sealed domain \* (<duration>, <real>);
define sealed domain \* (<real>, <duration>);
define sealed domain \/ (<duration>, <real>);

define sealed domain \= (<time>, <time>);
define sealed domain \= (<duration>, <duration>);
define sealed domain \< (<time>, <time>);
// TODO: <duration> < <integer> maybe?

// =

define method \= (t1 :: <time>, t2 :: <time>) => (_ :: <boolean>)
  t1.%days == t2.%days
    & t1.%nanoseconds == t2.%nanoseconds
end;

define method \= (d1 :: <duration>, d2 :: <duration>) => (_ :: <boolean>)
  d1.duration-nanoseconds == d2.duration-nanoseconds
end;

define method \< (t1 :: <time>, t2 :: <time>) => (_ :: <boolean>)
  let days1 = t1.%days;
  let days2 = t2.%days;
  days1 < days2 | (days1 == days2 & (t1.%nanoseconds < t2.%nanoseconds))
end;

define method \< (d1 :: <duration>, d2 :: <duration>) => (_ :: <boolean>)
  // TODO
end method;


// +

// Ouch. Heap allocating for these is kind of bad. Value types? Mutation?

define method \+ (t :: <time>, d :: <duration>) => (t :: <time>)
  let total-nanos = d.duration-nanoseconds;
  let days = floor/(total-nanos, $nanos/day);
  let nanos = total-nanos - days * $nanos/day;
  let new-days = t.%days + days;
  let new-nanos = t.%nanoseconds + nanos;
  if (abs(new-nanos) >= $nanos/day)
    new-days := new-days + if (new-nanos < 0) -1 else 1 end;
  end;
  make(<time>, days: new-days, nanoseconds: new-nanos)
end method;

define /* inline */ method \+ (d :: <duration>, t :: <time>) => (t :: <time>)
  t + d
end;

define method \+ (d1 :: <duration>, d2 :: <duration>) => (d :: <duration>)
  make(<duration>, nanoseconds: d1.duration-nanoseconds + d2.duration-nanoseconds)
end;

// -

// Returns the difference between time `t1` and time `t2` as a <duration>,
// which may be negative.
define method \- (t1 :: <time>, t2 :: <time>) => (d :: <duration>)
/*
  let sec1 = t1.%seconds;
  let sec2 = t2.%seconds;
  let nano1 = t1.%nanoseconds;
  let nano2 = t2.%nanoseconds;
  let seconds = sec1 - sec2;
  let nanoseconds = nano1 - nano2;
  if (nanoseconds < 0)
    seconds := seconds - 1;
    nanoseconds := 1_000_000_000 + nanoseconds;
  end;
  make(<duration>, nanoseconds: nanoseconds)
    */
  // TODO
  $nanosecond
end method;

define method \- (d1 :: <duration>, d2 :: <duration>) => (d :: <duration>)
  make(<duration>, nanoseconds: d1.duration-nanoseconds - d2.duration-nanoseconds)
end;

define method \- (t :: <time>, d :: <duration>) => (d :: <time>)
  let (days, nanos) = truncate/(d.duration-nanoseconds, $nanos/day);
  let days = t.%days - days;
  let nanos = t.%nanoseconds - nanos;
  if (nanos < 0)
    days := days - 1;
  end;
  make(<time>, days: days, nanoseconds: nanos)
end method;

// *

define method \* (d :: <duration>, r :: <real>) => (d :: <duration>)
  make(<duration>, nanoseconds: as(<integer>, d.duration-nanoseconds * r))
end;

define /* inline */ method \* (r :: <real>, d :: <duration>) => (d :: <duration>)
  d * r
end;

define /* inline */ method \/ (d :: <duration>, r :: <real>) => (d :: <duration>)
  make(<duration>, nanoseconds: floor/(d.duration-nanoseconds, r))
end method;


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

// Given year, month, and day, return the number of days since Gregorian 1970-01-01.
// Negative values indicate days prior to 1970-01-01.
define function days-from-civil
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

// Adjust `days` and `nanoseconds` to UTC time by subtracting `offset-nanos`,
// which could cross a day boundary. To adjust UTC to local pass the negated
// zone offset instead.  Returns the adjusted days and nanoseconds for
// constructing a `<time>`.
define inline function adjust-for-zone-offset
    (days :: <integer>, nanoseconds :: <integer>, offset-nanos :: <integer>)
 => (d :: <integer>, n :: <integer>)
  let nanos = nanoseconds - offset-nanos;
  if (nanos >= $nanos/day)
    days := days + 1;
    nanos := remainder(nanos, $nanos/day);
  elseif (nanos < 0)
    days := days - 1;
    nanos := nanos + $nanos/day;
  end;
  values(days, nanos)
end function;

define method compose-time
    (year :: <integer>, mon :: <month>, day :: <integer>, hour :: <integer>,
     min :: <integer>, sec :: <integer>, nano :: <integer>,
     #key zone :: <zone> = $utc)
 => (t :: <time>)
  let days = days-from-civil(year, month-number(mon), day);
  let nanoseconds = (hour * 60 * 60_000_000_000
                       + min * 60_000_000_000
                       + sec * 1_000_000_000
                       + nano);
  // TODO: this call to zone-offset-seconds ends up calling time-now() if `zone` is
  // aware. We shouldn't need to allocate an extra <time> to make a <time>. Make a
  // %zone-offset that accepts days and nanos and a %time-now that returns them?
  let (days, nanoseconds)
    = adjust-for-zone-offset(days, nanoseconds,
                             zone-offset-seconds(zone) * $nanos/second);
  make(<time>, days: days, nanoseconds: nanoseconds)
end method;

// Given a number of days relative to the epoch, either positive or negative, returns the
// year, month, and day in the Gregorian calendar.
define function civil-from-days
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

// $nanos/day should only be used for durations, which use idealized days.
define constant $nanos/day :: <integer> = 1_000_000_000 * 60 * 60 * 24;
define constant $nanos/hour :: <integer> = 3_600_000_000_000;
define constant $nanos/minute :: <integer> =  60_000_000_000;
define constant $nanos/second :: <integer> =   1_000_000_000;

define method time-components
    (t :: <time>, #key zone :: <zone> = $UTC)
 => (y :: <integer>, mon :: <month>, d :: <integer>, h :: <integer>,
     min :: <integer>, sec :: <integer>, nano :: <integer>, dow :: <day>)
  let offset-nanos = -(zone-offset-seconds(zone, time: t) * $nanos/second);
  let (days, nanos) = adjust-for-zone-offset(t.%days, t.%nanoseconds, offset-nanos);
  // TODO: it would be faster to bit-pack the hour/minute/second/nanos as
  // separate numbers (30+6+6+5=47 bits required) rather than doing all this
  // division.
  let (year, month, day) = civil-from-days(days);
  let month = as(<month>, month);
  let hour = floor/(nanos, $nanos/hour);
  nanos := nanos - hour * $nanos/hour;
  let minute = floor/(nanos, $nanos/minute);
  nanos := nanos - minute * $nanos/minute;
  let second = floor/(nanos, $nanos/second);
  let nano = nanos - second * $nanos/second;
  // Note: we return the zone to mirror encode-time.
  values(year, month, day, hour, minute, second, nano,
         // TODO: day of week
         $monday)
end method;


// --- Current time ---

// Returns the current time provided by the system's realtime clock.
define method time-now () => (t :: <time>)
  let spec = make(<timespec*>);
  let result = clock-gettime(get-clock-realtime(), spec);
  make(<time>,
       days: floor/(spec.timespec-seconds, 24 * 60 * 60),
       nanoseconds: spec.timespec-nanoseconds * 24 * 60 * 60)
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
  $january.month-long-name => $january,
  $february.month-long-name => $february,
  $march.month-long-name => $march,
  $april.month-long-name => $april,
  $may.month-long-name => $may,
  $june.month-long-name => $june,
  $july.month-long-name => $july,
  $august.month-long-name => $august,
  $september.month-long-name => $september,
  $october.month-long-name => $october,
  $november.month-long-name => $november,
  $december.month-long-name => $december
};

define table $short-name-to-month :: <string-table> = {
  $january.month-short-name => $january,
  $february.month-short-name => $february,
  $march.month-short-name => $march,
  $april.month-short-name => $april,
  $may.month-short-name => $may,
  $june.month-short-name => $june,
  $july.month-short-name => $july,
  $august.month-short-name => $august,
  $september.month-short-name => $september,
  $october.month-short-name => $october,
  $november.month-short-name => $november,
  $december.month-short-name => $december
};

define constant $minimum-time :: <time>
  = make(<time>, days: $minimum-integer, nanoseconds: 0);

// TODO: this may not be exactly right, considering leap seconds.
define constant $maximum-time :: <time>
  = make(<time>,
         days: $maximum-integer,
         nanoseconds: duration-nanoseconds($day - $nanosecond));
