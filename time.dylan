Module: time
Synopsis: Time and date APIs

// This module is designed to be used with or without a prefix on
// import.  If you find the short names to be in conflict with
// your code you may wish to import it like this:
//   use time, prefix: "time-";
//   use time, import: { <time>, <date>, <timezone> };

// TODO: on 32-bit platforms import <double-integer> as <integer> for
// use in both <time> and <duration>

// Basic accessors
define generic year   (t :: <time>) => (year :: <integer>);  // 1-...
define generic month  (t :: <time>) => (month :: <integer>); // 1-12
define generic day    (t :: <time>) => (day :: <integer>);   // 1-31
define generic hour   (t :: <time>) => (hour :: <integer>);  // 0-23
define generic minute (t :: <time>) => (minute :: <integer>); // 0-59
define generic second (t :: <time>) => (second :: <integer>); // 0-59
define generic nanosecond (t :: <time>) => (nanosecond :: <integer>);
define generic timezone (t :: <time>) => (zone :: <timezone>);
define generic timezone-setter (tz :: <timezone>, t :: <time>) => (tz :: <timezone>);

// ?? not sure the return type here. Maybe just <integer> is better.
define generic weekday (t :: <time>) => (day :: <weekday>);

// Current time and date.
define generic now () => (t :: <time>);
define generic today () => (d :: <date>);

// Conversion to/from strings.
define generic format (t :: <time>, #key pattern) => (s :: <string>);
define generic parse (s :: <string>, #key pattern, timezone) => (t :: <time>);

// A <time> represents an instant in time at a specific location (on
// Earth) to nanosecond precision.
define class <time> (<object>)
  slot seconds :: <integer> = 0,      init-keyword: seconds:,     setter: #f;
  slot nanoseconds :: <integer> = 0,  init-keyword: nanoseconds:, setter: #f;
  slot timezone :: <timezone> = $utc, init-keyword: timezone:;
end;

// <date> is simply a <time> with certain restrictions
// attached. Specifically, hours, minutes, seconds, and nanoseconds
// are always zero.
define class <date> (<time>)
end;

// Truncate `t` to the day by zeroing the hours, minutes, seconds, and nanoseconds.
define method as (class == <date>, t :: <time>) => (d :: <date>)
  // TODO
end;

// Returns true if `t1` and `t2` represent the same time instant. Two
// times can be equal even if they are in different timezones. For
// example, 6:00 +0200 CEST and 4:00 UTC are Equal.
define method \= (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let utc1 = as-utc(t1);
  let utc2 = as-utc(t2);
  utc1.seconds = utc2.seconds
    & utc1.nanoseconds = utc2.nanoseconds
end;

