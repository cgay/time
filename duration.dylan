Module: %time

define generic nanoseconds (d :: <duration>) => (nanoseconds :: <integer>);

// <duration> represents the difference between two times, in nanoseconds.  On
// 64 bit systems, with 2 tag bits, this gives a maximum duration of about 146
// years. On 32 bit systems, about 34 years.
define class <duration> (<object>)
  // TODO: This library uses generic-arithmetic so that this integer
  // can be 64-bits even on 32-bit systems. That isn't necessary on 64-bit.
  constant slot nanoseconds :: <integer> = 0,
    init-keyword: nanoseconds:;
end;

define constant $nanosecond :: <duration> = make(<duration>, nanoseconds: 1);
define constant $microsecond :: <duration> = make(<duration>, nanoseconds: 1_000);
define constant $millisecond :: <duration> = make(<duration>, nanoseconds: 1_000_000);
define constant $second :: <duration> = make(<duration>, nanoseconds: 1_000 * $millisecond);
define constant $minute :: <duration> = make(<duration>, nanoseconds: 60 * $second);
define constant $hour :: <duration> = make(<duration>, nanoseconds: 60 * $minute);

define sealed domain \= (<duration>, <duration>);
define sealed domain \< (<duration>, <duration>);
define sealed domain \+ (<duration>, <duration>);
define sealed domain \- (<duration>, <duration>);
define sealed domain \- (<time>, <duration>);
define sealed domain \= (<time>, <time>);
define sealed domain \- (<time>, <time>);
define sealed domain \* (<duration>, <real>);
define sealed domain \* (<real>, <duration>);
define sealed domain \/ (<duration>, <real>);

define method make (class == <duration>, #key nanoseconds :: <integer> = 0)
 => (duration :: <duration>)
  if (nanoseconds <= 0)
    time-error("durations must be non-negative (nanoseconds = %=)", nanoseconds);
  end;
  next-method(class, nanoseconds: nanoseconds)
end;

define method \= (d1 :: <duration>, d2 :: <duration>) => (equal? :: <boolean>)
  d1.nanoseconds = d2.nanoseconds
end;

define method \< (d1 :: <duration>, d2 :: <duration>) => (less? :: <boolean>)
  d1.nanoseconds < d2.nanoseconds
end;

// Oof. Heap allocating for these is kind of bad. Value types? Just use <integer>?

define method \+ (d1 :: <duration>, d2 :: <duration>) => (d :: <duration>)
  make(<duration>, nanoseconds: d1.nanoseconds + d2.nanoseconds)
end;

define method \- (d1 :: <duration>, d2 :: <duration>) => (d :: <duration>)
  make(<duration>, nanoseconds: d1.nanoseconds - d2.nanoseconds)
end;

define method \- (t1 :: <time>, t2 :: <time>) => (d :: <duration>)
  let utc1 = time-in-utc(t1);
  let utc2 = time-in-utc(t2);
  let seconds = %seconds(utc1) - %seconds(utc2);
  let nanoseconds = %nanoseconds(utc1) - %nanoseconds(utc2);
  seconds * 1_000_000_000 + nanoseconds
end;

define method \- (t :: <time>, d :: <duration>) => (d :: <duration>)
  let (seconds, nanos) = floor/(d.nanoseconds, 1_000_000_000);
  let seconds = t.%seconds - seconds;
  let nanos = t.%nanoseconds - nanos;
  if (nanos < 0)
    seconds := seconds - 1;
    nanos := abs(nanos);
  end;
  make(<time>, seconds: seconds, nanoseconds: nanos)
end method;

define method \+ (t :: <time>, d :: <duration>) => (t :: <time>)
  // TODO
  make(<time>)
end;

define method \+ (d :: <duration>, t :: <time>) => (t :: <time>)
  // TODO
  make(<time>)
end;

define method \* (d :: <duration>, r :: <real>) => (d :: <duration>)
  make(<duration>, nanoseconds: d.nanoseconds * r)
end;

define method \* (r :: <real>, d :: <duration>) => (d :: <duration>)
  d * r
end;

//// Conversions

define generic parse-duration (s :: <string>) => (d :: <duration>);

define method parse-duration (s :: <string>) => (d :: <duration>)
  // TODO
  make(<duration>)
end;

define generic format-duration (d :: <duration>, #key verbose) => (s :: <string>);

define method format-duration (d :: <duration>, fmt :: <string>) => (s :: <string>)
  // TODO: "5m 3s 435n" or "5 minutes 3 seconds" but how to indicate the amount of precision?
  // See what other languages do.
end;
