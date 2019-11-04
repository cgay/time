Module: %time

// TODO:
//
// * Decide how/whether to deal with monotonic clocks here.
//
// * Leap seconds.
//   https://docs.rs/chrono/*/chrono/naive/struct.NaiveTime.html#leap-second-handling
//
// * Calender operations? Could go in separate module or even library.
//
// * i18n - ensure that if someone wanted to they could make the days,
//   months, and date formats display/parse in non-English languages.


// Errors explicitly signalled by this library are instances of <time-error>.
define class <time-error> (<error>)
end;


define function time-error(msg :: <string>, #rest format-args)
  error(make(<time-error>,
             format-string: msg,
             format-arguments: format-args));
end;

//// Basic time accessors

define generic time-year         (t :: <time>) => (year :: <integer>);  // 1-...
define generic time-month        (t :: <time>) => (month :: <month>);
define generic time-day-of-month (t :: <time>) => (day :: <integer>);   // 1-31
define generic time-day-of-week  (t :: <time>) => (day :: <day>);
define generic time-hour         (t :: <time>) => (hour :: <integer>);  // 0-23
define generic time-minute       (t :: <time>) => (minute :: <integer>); // 0-59
define generic time-second       (t :: <time>) => (second :: <integer>); // 0-59
define generic time-nanosecond   (t :: <time>) => (nanosecond :: <integer>);
define generic time-zone         (t :: <time>) => (zone :: <time-zone>);

// Make a <time> that represents the same time instant as `t` but in a
// different zone.
define generic time-in-zone (t :: <time>, z :: <time-zone>) => (t2 :: <time>);
define generic time-in-utc (t :: <time>) => (utc :: <time>);

define method time-in-zone (t :: <time>, z :: <time-zone>) => (t2 :: <time>)
  // TODO: stub
  t
end;

define method time-in-utc (t :: <time>) => (utc :: <time>)
  time-in-zone(t, $utc)
end;


// Decompose `t` into its component parts for presentation.
define generic time-components
    (t :: <time>)
 => (year :: <integer>, month :: <month>, day-of-month :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, zone :: <time-zone>, day-of-week :: <day>);

define method time-components
    (t :: <time>)
 => (year :: <integer>, month :: <month>, day-of-month :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, zone :: <time-zone>, day-of-week :: <day>)
  // TODO: stub
  values(0, $january, 0, 0, 0, 0, 0, $utc, $monday)
end;

define generic make-time
    (year :: <integer>, month :: <integer>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>, #key zone)
 => (t :: <time>);

define method make-time
    (year :: <integer>, month :: <integer>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     #key zone :: <time-zone> = $utc)
 => (t :: <time>)
  // TODO: stub
  make(<time>, seconds: 0, nanoseconds: 0, zone: $utc)
end;

define method time-year (t :: <time>) => (year :: <integer>)
  time-components(t) // Only first value returned.
end;

define method time-month (t :: <time>) => (month :: <month>)
  let (_, month) = time-components(t);
  month
end;

define method time-day-of-month (t :: <time>) => (day-of-month :: <integer>)
  let (_, _, day-of-month) = time-components(t);
  day-of-month
end;

define method time-day-of-week (t :: <time>) => (_ :: <day>)
  let (_, _, _, _, _, _, _, _, day-of-week) = time-components(t);
  day-of-week
end;

define method time-hour (t :: <time>) => (hour :: <integer>)
  let (_, _, _, hour) = time-components(t);
  hour
end;

define method time-minute (t :: <time>) => (minute :: <integer>)
  let (_, _, _, _, minute) = time-components(t);
  minute
end;

define method time-second (t :: <time>) => (second :: <integer>)
  let (_, _, _, _, _, second) = time-components(t);
  second
end;

define method time-nanosecond (t :: <time>) => (nanosecond :: <integer>)
  let (_, _, _, _, _, _, nanosecond) = time-components(t);
  nanosecond
end;


//// Days of the week

// TODO: how to deal with starting the week on Sunday or Monday?
//       Maybe day-number doesn't even need to exist.
define generic day-number (w :: <day>) => (n :: <integer>);
define generic day-name (w :: <day>) => (n :: <string>);
define generic day-short-name (w :: <day>) => (n :: <string>);

define class <day> (<object>)
  constant slot day-number :: <integer>, required-init-keyword: number:;
  constant slot day-name :: <string>, required-init-keyword: name:;
  constant slot day-short-name :: <string>, init-keyword: short:;
end;

define constant $monday    :: <day> = make(<day>, number: 1, short: "Mon", name: "Monday");
define constant $tuesday   :: <day> = make(<day>, number: 2, short: "Tue", name: "Tuesday");
define constant $wednesday :: <day> = make(<day>, number: 3, short: "Wed", name: "Wednesday");
define constant $thursday  :: <day> = make(<day>, number: 4, short: "Thu", name: "Thursday");
define constant $friday    :: <day> = make(<day>, number: 5, short: "Fri", name: "Friday");
define constant $saturday  :: <day> = make(<day>, number: 6, short: "Sat", name: "Saturday");
define constant $sunday    :: <day> = make(<day>, number: 7, short: "Sun", name: "Sunday");

define constant $days
  = vector($monday, $tuesday, $wednesday, $thursday, $friday, $saturday, $sunday);

define method parse-day (name :: <string>) => (d :: <day>)
  element($short-name-to-day, name, default: #f)
    | element($name-to-day, name, default: #f)
    | time-error("%= is not a valid day name", name)
end;

define table $name-to-day :: <case-insensitive-string-table> = {
  $monday.day-name    => $monday,
  $tuesday.day-name   => $tuesday,
  $wednesday.day-name => $wednesday,
  $thursday.day-name  => $thursday,
  $friday.day-name    => $friday,
  $saturday.day-name  => $saturday,
  $sunday.day-name    => $sunday
};

define table $short-name-to-day :: <case-insensitive-string-table> = {
  $monday.day-short-name    => $monday,
  $tuesday.day-short-name   => $tuesday,
  $wednesday.day-short-name => $wednesday,
  $thursday.day-short-name  => $thursday,
  $friday.day-short-name    => $friday,
  $saturday.day-short-name  => $saturday,
  $sunday.day-short-name    => $sunday
};


// ===== Months

// month-number returns the 1-based month number for the given month.
// January = 1, February = 2, etc.
define generic month-number (m :: <month>) => (n :: <integer>);

// month-name returns the full name of the month. "January", "February", etc.
define generic month-name (m :: <month>) => (n :: <string>);

// month-short-name returns the 3-letter month name with an initial
// capital letter. "Jan", "Feb", etc.
define generic month-short-name (m :: <month>) => (n :: <string>);

// month-days returns the standard (non-leap year) dayays in the month.
// January = 31, February = 28, etc.
define generic month-days (m :: <month>) => (n :: <integer>);

define sealed class <month> (<object>)
  constant slot month-number :: <integer>,    required-init-keyword: number:;
  constant slot month-name :: <string>,       required-init-keyword: name:;
  constant slot month-short-name :: <string>, required-init-keyword: short:;
  constant slot month-days :: <integer>,      required-init-keyword: days:;
end;
  
define constant $january   :: <month> = make(<month>, number:  1, short: "Jan", days: 31, name: "January");
define constant $february  :: <month> = make(<month>, number:  2, short: "Feb", days: 28, name: "February");
define constant $march     :: <month> = make(<month>, number:  3, short: "Mar", days: 31, name: "March");
define constant $april     :: <month> = make(<month>, number:  4, short: "Apr", days: 30, name: "April");
define constant $may       :: <month> = make(<month>, number:  5, short: "May", days: 31, name: "May");
define constant $june      :: <month> = make(<month>, number:  6, short: "Jun", days: 30, name: "June");
define constant $july      :: <month> = make(<month>, number:  7, short: "Jul", days: 31, name: "July");
define constant $august    :: <month> = make(<month>, number:  8, short: "Aug", days: 31, name: "August");
define constant $september :: <month> = make(<month>, number:  9, short: "Sep", days: 30, name: "September");
define constant $october   :: <month> = make(<month>, number: 10, short: "Oct", days: 31, name: "October");
define constant $november  :: <month> = make(<month>, number: 11, short: "Nov", days: 30, name: "November");
define constant $december  :: <month> = make(<month>, number: 12, short: "Dec", days: 31, name: "December");

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
  $january.month-name => $january,
  $february.month-name => $february,
  $march.month-name => $march,
  $april.month-name => $april,
  $may.month-name => $may,
  $june.month-name => $june,
  $july.month-name => $july,
  $august.month-name => $august,
  $september.month-name => $september,
  $october.month-name => $october,
  $november.month-name => $november,
  $december.month-name => $december
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

// Returns the current time in the local time zone, or in `zone` if supplied.
// For example, `current-time(zone: $utc)` returns the current UTC time.
define function current-time (#key zone :: false-or(<time-zone>)) => (t :: <time>)
  let zone = zone | local-time-zone();
  // TODO
  c-clock-gettime
end;

// Conversion to/from strings.
define generic format-time (t :: <time>, #key pattern) => (s :: <string>);
define generic parse-time (s :: <string>, #key pattern, zone) => (t :: <time>);

// A `<time>` represents an instant in time, to nanosecondd precision. It has a
// zone associated with it, which affects presentation only.  `<time>`
// instances are normally created by calling `current-time()` or
// `make-time(year, month, day, ...)`, or by adding/subtracting a time and a
// duration.
//
// TODO: This entire library is using generic-arithmetic so that these two
// slots can hold values bigger than 30-bit signed integers on 32-bit
// platforms. There's no need to use generic-arithmetic on 64-bit as long as
// seconds and nanoseconds are maintained in separate slots.
define class <time> (<object>)
  // Seconds and nanoseconds since the UNIX Epoch.
  constant slot %seconds :: <integer> = 0,     init-keyword: seconds:;
  constant slot %nanoseconds :: <integer> = 0, init-keyword: nanoseconds:;

  // Zone is ONLY for display. That is, when `format-time`, `time-components`,
  // or a few other related functions are called the zone is used, but time
  // calculations generally ignore it.
  constant slot %zone :: <time-zone> = $utc,   init-keyword: zone:;
end;

define constant $epoch :: <time>
  = make(<time>, seconds: 0, nanoseconds: 0);

define constant $utc :: <time-zone>
  = make(<time-zone>, name: "UTC", offsets: vector(pair($epoch, 0)));

define function local-time-zone () => (zone :: <time-zone>)
  // TODO
  $utc
end;

define method time-zone (t :: <time>) => (zone :: <time-zone>)
  t.%zone
end;

define sealed domain \= (<time>, <time>);
define sealed domain \< (<time>, <time>);
define sealed domain \- (<time>, <time>);  // => <duration>


// Returns true if `t1` and `t2` represent the same time instant. Two
// times can be equal even if they are in different zones. For
// example, 6:00 +0200 CEST and 4:00 UTC are equal.
define method \= (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let utc1 = time-in-utc(t1);
  let utc2 = time-in-utc(t2);
  time-second(utc1) = time-second(utc2)
    & time-nanosecond(utc1) = time-nanosecond(utc2)
end;

define method \< (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let utc1 = time-in-utc(t1);
  let utc2 = time-in-utc(t2);
  let sec1 = time-second(utc1);
  let sec2 = time-second(utc2);
  sec1 < sec2 | (sec1 == sec2 & (time-nanosecond(utc1) < time-nanosecond(utc2)))
end;

// e.g., truncate(t, $hour) for 5:32 => 5:00
define generic truncate-time (t :: <time>, d :: <duration>) => (t :: <time>);

define method truncate-time (t :: <time>, d :: <duration>) => (t :: <time>)
  if (d < $second)
    let nanos = truncate(t.%nanoseconds, d.nanoseconds);
    make(<time>, seconds: t.%seconds, nanoseconds: nanos)
  elseif (d > $second)
    let seconds = truncate(t.%seconds, truncate(d.nanoseconds, 1_000_000_000));
    make(<time>, seconds: seconds, nanoseconds: 0)
  end
end method;
    
