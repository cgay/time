Module: %time

// TODO:
//
// * Decide how/whether to deal with monotonic clocks here.
//
// * Leap seconds.
//   https://docs.rs/chrono/*/chrono/naive/struct.NaiveTime.html#leap-second-handling
//
// * Calender operations / dates / year/month durations.
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

// Basic time accessors
define generic time-year       (t :: <time>) => (year :: <integer>);  // 1-...
define generic time-month      (t :: <time>) => (month :: <month>);
define generic time-day        (t :: <time>) => (day :: <integer>);   // 1-31
define generic time-hour       (t :: <time>) => (hour :: <integer>);  // 0-23
define generic time-minute     (t :: <time>) => (minute :: <integer>); // 0-59
define generic time-second     (t :: <time>) => (second :: <integer>); // 0-59
define generic time-nanosecond (t :: <time>) => (nanosecond :: <integer>);
define generic time-zone       (t :: <time>) => (zone :: <zone>);

// Make a <time> that represents the same time instant as `t` but in a
// different zone.
define generic time-in-zone (t :: <time>, z :: <zone>) => (t2 :: <time>);
define generic time-in-utc (t :: <time>) => (utc :: <time>);

define method time-in-zone (t :: <time>, z :: <zone>) => (t2 :: <time>)
  // TODO: stub
  t
end;

define method time-in-utc (t :: <time>) => (utc :: <time>)
  time-in-zone(t, $utc)
end;


// Decompose `t` into its component parts for presentation.
define generic decode-time
    (t :: <time>)
 => (year :: <integer>, month :: <month>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, zone :: <zone>);

define method decode-time
    (t :: <time>)
 => (year :: <integer>, month :: <month>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, zone :: <zone>)
  // TODO: stub
  values(0, $january, 0, 0, 0, 0, 0, $utc)
end;

define generic encode-time
    (year :: <integer>, month :: <integer>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>, #key zone)
 => (t :: <time>);

define method encode-time
    (year :: <integer>, month :: <integer>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     #key zone :: <zone> = $utc)
 => (t :: <time>)
  // TODO: stub
  make(<time>, seconds: 0, nanoseconds: 0, zone: $utc)
end;

define method time-year (t :: <time>) => (year :: <integer>)
  decode-time(t) // Only first value returned.
end;

define method time-month (t :: <time>) => (month :: <month>)
  let (_, month) = decode-time(t);
  month
end;

define method time-day (t :: <time>) => (day :: <integer>)
  let (_, _, day) = decode-time(t);
  day
end;

define method time-hour (t :: <time>) => (hour :: <integer>)
  let (_, _, _, hour) = decode-time(t);
  hour
end;

define method time-minute (t :: <time>) => (minute :: <integer>)
  let (_, _, _, _, minute) = decode-time(t);
  minute
end;

define method time-second (t :: <time>) => (second :: <integer>)
  let (_, _, _, _, _, second) = decode-time(t);
  second
end;

define method time-nanosecond (t :: <time>) => (nanosecond :: <integer>)
  let (_, _, _, _, _, _, nanosecond) = decode-time(t);
  nanosecond
end;


// ===== Weekdays

// Weekday accessors
define generic weekday-number (w :: <weekday>) => (n :: <integer>);
define generic weekday-name (w :: <weekday>) => (n :: <string>);
define generic weekday-short-name (w :: <weekday>) => (n :: <string>);

define class <weekday> (<object>)
  constant slot weekday-number :: <integer>, required-init-keyword: number:;
  constant slot weekday-name :: <string>, required-init-keyword: name:;
  constant slot weekday-short-name :: <string>, init-keyword: short:;
end;

define constant $monday    :: <weekday> = make(<weekday>, number: 1, short: "Mon", name: "Monday");
define constant $tuesday   :: <weekday> = make(<weekday>, number: 2, short: "Tue", name: "Tuesday");
define constant $wednesday :: <weekday> = make(<weekday>, number: 3, short: "Wed", name: "Wednesday");
define constant $thursday  :: <weekday> = make(<weekday>, number: 4, short: "Thu", name: "Thursday");
define constant $friday    :: <weekday> = make(<weekday>, number: 5, short: "Fri", name: "Friday");
define constant $saturday  :: <weekday> = make(<weekday>, number: 6, short: "Sat", name: "Saturday");
define constant $sunday    :: <weekday> = make(<weekday>, number: 7, short: "Sun", name: "Sunday");

define constant $weekdays
  = vector($monday, $tuesday, $wednesday, $thursday, $friday, $saturday, $sunday);

define method as (class == <weekday>, n :: <integer>) => (d :: <weekday>)
  if (n < 1 | n > 7)
    time-error("invalid weekday index %d outside the range 1..7", n);
  end;
  $weekdays[n - 1]
end;

define method as (class == <weekday>, name :: <string>) => (d :: <weekday>)
  if (size(name) == 3)
    element($short-name-to-weekday, name, default: #f)
  else
    element($name-to-weekday, name, default: #f)
  end
  | time-error("%= does not designate a valid weekday", name)
end;

define table $name-to-weekday :: <string-table> = {
  $monday.weekday-name    => $monday,
  $tuesday.weekday-name   => $tuesday,
  $wednesday.weekday-name => $wednesday,
  $thursday.weekday-name  => $thursday,
  $friday.weekday-name    => $friday,
  $saturday.weekday-name  => $saturday,
  $sunday.weekday-name    => $sunday
};
define table $short-name-to-weekday :: <string-table> = {
  $monday.weekday-short-name    => $monday,
  $tuesday.weekday-short-name   => $tuesday,
  $wednesday.weekday-short-name => $wednesday,
  $thursday.weekday-short-name  => $thursday,
  $friday.weekday-short-name    => $friday,
  $saturday.weekday-short-name  => $saturday,
  $sunday.weekday-short-name    => $sunday
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

// Current time and date.
define generic current-time () => (t :: <time>);


// Conversion to/from strings.
define generic format-time (t :: <time>, #key pattern) => (s :: <string>);
define generic parse-time (s :: <string>, #key pattern, zone) => (t :: <time>);

// A <time> represents an instant in time at a specific location (on
// Earth) to nanosecond precision.
//
define class <time> (<object>)

  // TODO: This entire library is using generic-arithmetic so that
  // these two slots can hold values bigger than 30-bit signed
  // integers on 32-bit platforms. There's no need to use
  // generic-arithmetic on 64-bit as long as seconds and nanoseconds
  // are maintained in separate slots.
  slot %seconds :: <integer> = 0,     init-keyword: seconds:,     setter: #f;
  slot %nanoseconds :: <integer> = 0, init-keyword: nanoseconds:, setter: #f;

  slot %zone :: <zone> = $utc, init-keyword: zone:;
end;

define sealed domain \= (<time>, <time>);
define sealed domain \< (<time>, <time>);

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
