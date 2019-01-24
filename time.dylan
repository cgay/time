Module: time
Synopsis: Time and date APIs

// This module is designed to be used with or without a prefix on
// import.  If you find the short names to be in conflict with
// your code you may wish to import it like this:
//   use time, prefix: "time-";
//   use time, import: { <time>, <date>, <month>, <weekday>, <timezone> };

// TODO:
//
// * Decide how/whether to deal with monotonic clocks here.
//
// * i18n - ensure that if someone wanted to they could make the days,
//   months, and date formats display/parse in non-English languages.
//
// * Leap seconds.
//   https://docs.rs/chrono/*/chrono/naive/struct.NaiveTime.html#leap-second-handling
//
// * Calender operations / dates / year/month durations.


// Errors explicitly signalled by this library are instances of <time-error>.
define class <time-error> (<error>)
end;

define function time-error(msg :: <string>, #rest format-args)
  error(make(<time-error>,
             format-string: msg,
             format-arguments: format-args));
end;

// Basic time accessors
define generic year        (t :: <time>)   => (year :: <integer>);  // 1-...

// month returns a <month> object from the given month designator
// which may be one of these things:
//   * a 1-based index where 1 = January, 2 = February, etc.
//   * a 3-letter English month name like "Jan" or "feb", ignoring case.
//   * a full English month name like "January" or "february", ignoring case.
//   * a <time> object.
// Signals <time-error> if the designator does not identify a month.
define generic month       (o :: <object>) => (month :: <month>);

define generic day         (t :: <time>)   => (day :: <integer>);   // 1-31
define generic hour        (t :: <time>)   => (hour :: <integer>);  // 0-23
define generic minute      (t :: <time>)   => (minute :: <integer>); // 0-59
define generic second      (t :: <time>)   => (second :: <integer>); // 0-59
define generic nanosecond  (t :: <time>)   => (nanosecond :: <integer>);
define generic zone        (t :: <time>)   => (zone :: <timezone>);

// weekday returns a <weekday> object from the given weekday designator
// which may be one of these things:
//   * a 1-based index where 1 = Monday, 2 = Tuesday, etc.
//   * a 3-letter English weekday name like "Mon" or "tue", ignoring case.
//   * a full English weekday name like "Monday" or "tuesday", ignoring case.
//   * a <time> object.
// Signals <time-error> if the designator does not identify a weekday.
define generic weekday     (o :: <object>) => (day :: <weekday>);

// Make a <time> that represents the same time instant as `t` but in a
// different timezone.
define generic in-zone (t :: <time>, z :: <timezone>) => (t2 :: <time>);

// Decompose `t` into its component parts for presentation.
define generic decode-time
    (t :: <time>)
 => (year :: <integer>, month :: <month>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, timezone :: <timezone>);

define method decode-time
    (t :: <time>)
 => (year :: <integer>, month :: <month>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, timezone :: <timezone>)
  let abs :: <integer> = absolute-time(t);
  let days :: <integer> = floor/(abs, $seconds-per-day);
  // ...
end;

define generic encode-time
    (year :: <integer>, month :: <integer>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>, #key zone)
 => (d :: <time>);


// ===== Weekdays

// Weekday accessors
define generic weekday-number (w :: <weekday>) => (n :: <integer>);
define generic weekday-name (w :: <weekday>) => (n :: <string>);
define generic weekday-short-name (w :: <weekday>) => (n :: <string>);

define class <weekday> (<object>)
  constant slot weekday-number, required-init-keyword: number:;
  constant slot weekday-name, required-init-keyword: name:;
  constant slot weekday-short-name, init-keyword: short:;
end;

define constant $monday    = make(<weekday>, number: 1, short: "Mon", name: "Monday");
define constant $tuesday   = make(<weekday>, number: 2, short: "Tue", name: "Tuesday");
define constant $wednesday = make(<weekday>, number: 3, short: "Wed", name: "Wednesday");
define constant $thursday  = make(<weekday>, number: 4, short: "Thu", name: "Thursday");
define constant $friday    = make(<weekday>, number: 5, short: "Fri", name: "Friday");
define constant $saturday  = make(<weekday>, number: 6, short: "Sat", name: "Saturday");
define constant $sunday    = make(<weekday>, number: 7, short: "Sun", name: "Sunday");

define constant $days
  = vector($monday, $tuesday, $wednesday, $thursday, $friday, $saturday, $sunday);

define method weekday (n :: <integer>) => (m :: <weekday>)
  if (n < 1 | n > 7)
    time-error("invalid weekday index %d outside the range 1..7", n);
  end;
  $days[n]
end;

define method weekday (name :: <string>) => (m :: <weekday>)
  if (size(name) == 3)
    element($short-name-to-weekday, name, default: #f)
  else
    element($name-to-weekday, name, default: #f)
  end
  | time-error("%= does not designate a valid weekday", name)
end;

define method weekday (t :: <time>) => (m :: <weekday>)
  // TODO: calendar ops
end;

define table $name-to-weekday :: <string-table> = {
  $monday.day-name    => $monday,
  $tuesday.day-name   => $tuesday,
  $wednesday.day-name => $wednesday,
  $thursday.day-name  => $thursday,
  $friday.day-name    => $friday,
  $saturday.day-name  => $saturday,
  $sunday.day-name    => $sunday
};
define table $short-name-to-weekday :: <string-table> = {
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
define generic month-number     (m :: <month>) => (n :: <integer>);

// month-name returns the full name of the month. "January", "February", etc.
define generic month-name       (m :: <month>) => (n :: <string>);

// month-short-name returns the 3-letter month name with an initial
// capital letter. "Jan", "Feb", etc.
define generic month-short-name (m :: <month>) => (n :: <string>);

// month-days returns the standard (non-leap year) dayays in the month.
// January = 31, February = 28, etc.
define generic month-days       (m :: <month>) => (n :: <integer>);

define sealed class <month> (<object>)
  constant slot month-number :: <integer>,    required-init-keyword: number:;
  constant slot month-name :: <string>,       required-init-keyword: name:;
  constant slot month-short-name :: <string>, required-init-keyword: short:;
  constant slot month-days :: <integer>,      required-init-keyword: days:;
end;
  
define constant $january   = make(<month>, number:  1, short: "Jan", days: 31, name: "January");
define constant $february  = make(<month>, number:  2, short: "Feb", days: 28, name: "February");
define constant $march     = make(<month>, number:  3, short: "Mar", days: 31, name: "March");
define constant $april     = make(<month>, number:  4, short: "Apr", days: 30, name: "April");
define constant $may       = make(<month>, number:  5, short: "May", days: 31, name: "May");
define constant $june      = make(<month>, number:  6, short: "Jun", days: 30, name: "June");
define constant $july      = make(<month>, number:  7, short: "Jul", days: 31, name: "July");
define constant $august    = make(<month>, number:  8, short: "Aug", days: 31, name: "August");
define constant $september = make(<month>, number:  9, short: "Sep", days: 30, name: "September");
define constant $october   = make(<month>, number: 10, short: "Oct", days: 31, name: "October");
define constant $november  = make(<month>, number: 11, short: "Nov", days: 30, name: "November");
define constant $december  = make(<month>, number: 12, short: "Dec", days: 31, name: "December");

define constant $months
  = vector($january, $february, $march, $april, $may, $june, $july,
           $august, $september, $october, $november, $december);

define method month (n :: <integer>) => (m :: <month>)
  if (n < 1 | n > 12)
    time-error("invalid month index %d outside the range 1..12", n);
  end;
  $months[n]
end;

define method month (name :: <string>) => (m :: <month>)
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
define generic now () => (t :: <time>);
define generic today () => (d :: <date>);

// Conversion to/from strings.
define generic format-time (t :: <time>, #key pattern) => (s :: <string>);
define generic parse-time (s :: <string>, #key pattern, timezone) => (t :: <time>);

// A <time> represents an instant in time at a specific location (on
// Earth) to nanosecond precision.
define class <time> (<object>)
  slot %seconds :: <integer> = 0,      init-keyword: seconds:,     setter: #f;
  slot %nanoseconds :: <integer> = 0,  init-keyword: nanoseconds:, setter: #f;
  slot %timezone :: <timezone> = $utc, init-keyword: timezone:;
end;

// Truncate `t` to the day by zeroing the hours, minutes, seconds, and nanoseconds.
define method as (class == <date>, t :: <time>) => (d :: <date>)
  // TODO
end;

define sealed domain \= (<time>, <time>);
define sealed domain \< (<time>, <time>);
define sealed domain \- (<time>, <time>); // => <duration>

// Returns true if `t1` and `t2` represent the same time instant. Two
// times can be equal even if they are in different timezones. For
// example, 6:00 +0200 CEST and 4:00 UTC are Equal.
define method \= (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let utc1 = as-utc(t1);
  let utc2 = as-utc(t2);
  utc1.seconds = utc2.seconds
    & utc1.nanoseconds = utc2.nanoseconds
end;

define method \< (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let utc1 = as-utc(t1);
  let utc2 = as-utc(t2);
  let sec1 = utc1.seconds;
  let sec2 = utc2.seconds;
  sec1 < sec2 | (sec1 == sec2 & (utc1.nanoseconds < utc2.nanoseconds))
end;

define method \- (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let utc1 = as-utc(t1);
  let utc2 = as-utc(t2);
  utc1.seconds = utc2.seconds
    & utc1.nanoseconds = utc2.nanoseconds
end;
