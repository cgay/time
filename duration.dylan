Module: time

// <duration> represents the difference between two times, in
// nanoseconds.  On 64 bit systems, with 2 tag bits, this gives a
// maximum duration of about 146 years.
define class <duration> (<object>)
  constant slot nanoseconds :: <integer> = 0,
    init-keyword: nanoseconds:;
end;

define constant $one-day  :: <duration> = make(<duration>, days: 1);
define constant $one-hour :: <duration> = make(<duration>, hours: 1);
define constant $one-minute :: <duration> = make(<duration>, minutes: 1);
define constant $one-second :: <duration> = make(<duration>, seconds: 1);
define constant $one-millisecond :: <duration> = make(<duration>, milliseconds: 1);
define constant $one-microsecond :: <duration> = make(<duration>, microseconds: 1);
define constant $one-nanosecond :: <duration> = make(<duration>, nanoseconds: 1);

// e.g., truncate(t, $one-hour)
define generic truncate (t :: <time>, d :: <duration>) => (t :: <time>);

define sealed domain \= (<duration>, <duration>);
define sealed domain \< (<duration>, <duration>);
define sealed domain \+ (<duration>, <duration>);
define sealed domain \+ (<date>, <duration>);
define sealed domain \+ (<duration>, <date>);
define sealed domain \- (<duration>, <duration>);
// no: define sealed domain \- (<date>, <date>);
define sealed domain \- (<date>, <duration>);
define sealed domain \* (<duration>, <real>);
define sealed domain \* (<real>, <duration>);
define sealed domain \/ (<duration>, <real>);

define method make (class == <duration>, #rest init-keywords,
                                         #key days :: false-or(<integer>) = #f,
                                              hours :: false-or(<integer>) = #f,
                                              minutes :: false-or(<integer>) = #f,
                                              seconds :: false-or(<integer>) = #f,
                                              microseconds :: false-or(<integer>) = #f,
                                         #all-keys)
 => (duration :: <duration>)

/// Addition of times, dates, and durations. Methods on <date> are not
/// necessary since <date> is a subclass of <time>.  Adding a <duration>
/// to a <date> always returns a direct instance of <time>.

define method \+ (t :: <time>, d :: <duration>) => (t :: <time>)
  // TODO
end;

define method \+ (d :: <duration>, t :: <time>) => (t :: <time>)
  // TODO
end;

/// Subtraction of times, dates, and durations

define method \- (t :: <time>, d :: <duration>) => (t :: <time>)
  // TODO
end;

