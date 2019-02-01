Module: %time

// define generic nanoseconds ...?

// <duration> represents the difference between two times, in
// nanoseconds.  On 64 bit systems, with 2 tag bits, this gives a
// maximum duration of about 146 years.
define class <duration> (<object>)
  // TODO: This library uses generic-arithmetic so that this integer
  // can be 64-bits even on 32-bit systems. That isn't necessary on 64-bit.
  constant slot nanoseconds :: <integer> = 0,
    init-keyword: nanoseconds:;
end;

define constant $one-day  :: <duration> = make(<duration>, days: 1);
define constant $one-hour :: <duration> = make(<duration>, hours: 1);
define constant $one-minute :: <duration> = make(<duration>, minutes: 1);
define constant $one-second :: <duration> = make(<duration>, seconds: 1);
define constant $one-millisecond :: <duration> = make(<duration>, nanoseconds: 1000000);
define constant $one-microsecond :: <duration> = make(<duration>, nanoseconds: 1000);
define constant $one-nanosecond :: <duration> = make(<duration>, nanoseconds: 1);

// e.g., truncate(t, $one-hour) for 5:32 => 5:00
define generic truncate-time (t :: <time>, d :: <duration>) => (t :: <time>);

define sealed domain \= (<duration>, <duration>);
define sealed domain \< (<duration>, <duration>);
define sealed domain \+ (<duration>, <duration>);
define sealed domain \- (<duration>, <duration>);
define sealed domain \* (<duration>, <real>);
define sealed domain \* (<real>, <duration>);
define sealed domain \/ (<duration>, <real>);

define method make (class == <duration>,
                    #rest init-keywords,
                    #key days :: <integer> = 0,
                         hours :: <integer> = 0,
                         minutes :: <integer> = 0,
                         seconds :: <integer> = 0,
                         nanoseconds :: <integer> = 0)
 => (duration :: <duration>)
  let n/s :: <integer> = 1000000000; // nanos per second
  let s :: <integer> = seconds * n/s;
  let m :: <integer> = minutes * 60 * n/s;
  let h :: <integer> = hours * 60 * 60 * n/s;
  let d :: <integer> = days * 24 * 60 * 60 * n/s;
  next-method(class, nanoseconds: d + h + m + s + nanoseconds)
end;

define sealed domain \- (<time>, <time>); // => <duration>

define method \- (t1 :: <time>, t2 :: <time>) => (d :: <duration>)
  let utc1 = time-in-utc(t1);
  let utc2 = time-in-utc(t2);
  let seconds = %seconds(utc1) - %seconds(utc2);
  let nanoseconds = %nanoseconds(utc1) - %nanoseconds(utc2);
  seconds * 1000000000 + nanoseconds
end;

/// Addition of times, dates, and durations.

define method \+ (t :: <time>, d :: <duration>) => (t :: <time>)
  // TODO
  make(<time>)
end;

define method \+ (d :: <duration>, t :: <time>) => (t :: <time>)
  // TODO
  make(<time>)
end;

/// Subtraction of times, dates, and durations

define method \- (t :: <time>, d :: <duration>) => (t :: <time>)
  // TODO
  make(<time>)
end;

define method as (class == <duration>, nanos :: <integer>) => (d :: <duration>)
  // TODO
  make(<duration>)
end;

// 2h1m20s etc
define method as (class == <duration>, s :: <string>) => (d :: <duration>)
  // TODO
  make(<duration>)
end;
