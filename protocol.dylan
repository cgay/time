Module: %time
Synopsis: Public interfaces for the time module

// Errors explicitly signaled by this library are instances of <time-error>.
define class <time-error> (<error>) end;


//// ==== Zones

define abstract class <zone> (<object>)
end class;

define constant $utc :: <naive-zone>
  = make(<naive-zone>,
         long-name: "Coordinated Universal Time",
         short-name: "UTC",
         offset: 0);

// The short for the zone, like "UTC" or "CET". If a zone has no short name it
// defaults to the value of zone-offset-string() for the current time. If the
// zone has no offset at the current time it defaults to $unknown-zone-name.
define sealed generic zone-short-name (z :: <zone>) => (name :: <string>);

// The long name for the zone, like "Coordinated Universal Time" or "Central
// European Time". If a zone has no name it defaults to the value of
// zone-offset-string() for the current time. If the zone has no offset at the
// current time it defaults to "???".
define sealed generic zone-long-name (z :: <zone>) => (name :: <string>);

// The number of minutes offset from UTC for zone `z` at time `time`.
// If `time` is not provided it defaults to the current time.
//
// TODO: not quite right. <time> has a <zone> but we pass the time to the zone
// to determine the offset.
define sealed generic zone-offset (z :: <zone>, #key time) => (minutes :: <integer>);

// Returns a string describing the offset from UTC for zone `z` at time `time`.
// For example, "+0000" for UTC itself or "-0400" for EDT. Use
// `zone-short-name` if you want to display the mnemonic zone name instead. If
// this zone didn't exist at `time` a <time-error> is signaled.
define sealed generic zone-offset-string (z :: <zone>, #key time) => (offset :: <string>);

// If `colon?` is true then use +00:00, else use +0000.  If `utc-name` is
// provided, output that string for a naive zone with offset 0 instead of the
// numeric format. Ex: `utc-name: "Z"`
define generic format-zone-offset
  (stream :: <stream>, zone :: <zone>, #key colon?, utc-name) => ();


//// ==== Time

// A <time> represents an instant in time, to nanosecondd precision. It may
// have a zone associated with it, which affects presentation methods such as
// format-time and time-components. If it has no zone it is a UTC time.
define class <time> (<object>)
  constant slot %seconds :: <integer> = 0,     init-keyword: seconds:;
  constant slot %nanoseconds :: <integer> = 0, init-keyword: nanoseconds:;
  constant slot %zone :: <zone> = $utc,   init-keyword: zone:;
end;

define constant $epoch :: <time>
  = make(<time>, seconds: 0, nanoseconds: 0, zone: $utc);

define sealed generic time-year         (t :: <time>) => (year :: <integer>);  // 1-...
define sealed generic time-month        (t :: <time>) => (month :: <month>);
//             time-day-of-year?
define sealed generic time-day-of-month (t :: <time>) => (day :: <integer>);   // 1-31
define sealed generic time-day-of-week  (t :: <time>) => (day :: <day>);
define sealed generic time-hour         (t :: <time>) => (hour :: <integer>);  // 0-23
define sealed generic time-minute       (t :: <time>) => (minute :: <integer>); // 0-59
define sealed generic time-second       (t :: <time>) => (second :: <integer>); // 0-59
define sealed generic time-nanosecond   (t :: <time>) => (nanosecond :: <integer>);
define sealed generic time-zone         (t :: <time>) => (zone :: <zone>);

// Returns the current time in the local time zone, or in `zone` if supplied.
// For example, time-now(zone: $utc) returns the current UTC time.
//
define sealed generic time-now (#key zone) => (t :: <time>);

// Make a <time> that represents the same time instant as `t` but in a
// different zone.
define sealed generic time-in-zone (t :: <time>, z :: <zone>) => (t2 :: <time>);
define sealed generic time-in-utc (t :: <time>) => (utc :: <time>);

// Decompose `t` into its component parts for presentation.
define sealed generic time-components
    (t :: <time>)
 => (year :: <integer>, month :: <month>, day-of-month :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, zone :: <zone>, day-of-week :: <day>);

define sealed generic make-time
    (year :: <integer>, month :: <integer>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>, #key zone)
 => (t :: <time>);

define sealed generic print-time
    (time :: <time>, #key stream, format) => ();

define sealed generic format-time
    (stream :: <stream>, format :: <object>, time :: <time>) => ();

define sealed generic parse-time
    (time :: <string>, #key format, zone) => (time :: <time>);

// TODO:
// define sealed generic round-time (t :: <time>, d :: <duration>) => (t :: <time>);
// define sealed generic truncate-time (t :: <time>, d :: <duration>) => (t :: <time>);


//// ==== Durations

define sealed generic duration-nanoseconds (d :: <duration>) => (nanoseconds :: <integer>);

// <duration> represents the difference between two times, in nanoseconds. They
// may be positive or negative. On 64 bit systems, with 2 tag bits, this gives
// a maximum duration of about 146 years. Durations are non-negative.
//
// TODO: This library uses generic-arithmetic so that this integer can be
// 64-bits even on 32-bit systems. Use platform-specific build files.
define class <duration> (<object>)
  constant slot duration-nanoseconds :: <integer> = 0,
    init-keyword: nanoseconds:;
end;

define constant $nanosecond :: <duration>  = make(<duration>, nanoseconds:          1);
define constant $microsecond :: <duration> = make(<duration>, nanoseconds:      1_000);
define constant $millisecond :: <duration> = make(<duration>, nanoseconds:  1_000_000);
define constant $second :: <duration> = make(<duration>, nanoseconds:   1_000_000_000);
define constant $minute :: <duration> = make(<duration>, nanoseconds:  60_000_000_000);
define constant $hour :: <duration> = make(<duration>, nanoseconds: 3_600_000_000_000);

define sealed generic print-duration
    (duration :: <duration>, #key stream, format, precision) => ();

define sealed generic parse-duration
    (string :: <string>) => (duration :: <duration>);

define sealed generic format-duration
    (stream :: <stream>, format :: <object>, duration :: <duration>, precision :: <duration>)
 => ();


//// ==== Conversions

define sealed domain \+ (<duration>, <duration>);
define sealed domain \+ (<time>, <duration>);
define sealed domain \+ (<duration>, <time>);
define sealed domain \- (<duration>, <duration>);
define sealed domain \- (<time>, <duration>);
define sealed domain \* (<duration>, <real>);
define sealed domain \* (<real>, <duration>);
define sealed domain \/ (<duration>, <real>);


//// ==== Comparisons

define sealed domain \= (<time>, <time>);
define sealed domain \= (<duration>, <duration>);
define sealed domain \< (<time>, <time>);
define sealed domain \- (<time>, <time>);


//// ==== Formatting and parsing

// Describes a format for outputting a <time>. See $rfc3339 below for an example.
define class <time-format> (<object>)
  constant slot time-format-original :: <string>,
    required-init-keyword: original:; // descriptor? pattern? string?
  constant slot time-format-parsed :: <sequence>,
    init-keyword: parsed:;
end class;

define constant $rfc3339
  = make(<time-format>, original: "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}{offset}");


//// ==== Days

// TODO: do we need day-number => 1..7?
define sealed generic day-long-name (d :: <day>) => (name :: <string>);
define sealed generic day-short-name (d :: <day>) => (name :: <string>);
define sealed generic parse-day (name :: <string>) => (day :: <day>);

define sealed class <day> (<object>)
  constant slot day-long-name :: <string>, required-init-keyword: long-name:;
  constant slot day-short-name :: <string>, required-init-keyword: short-name:;
end class;

define constant $monday    :: <day> = make(<day>, short-name: "Mon", long-name: "Monday");
define constant $tuesday   :: <day> = make(<day>, short-name: "Tue", long-name: "Tuesday");
define constant $wednesday :: <day> = make(<day>, short-name: "Wed", long-name: "Wednesday");
define constant $thursday  :: <day> = make(<day>, short-name: "Thu", long-name: "Thursday");
define constant $friday    :: <day> = make(<day>, short-name: "Fri", long-name: "Friday");
define constant $saturday  :: <day> = make(<day>, short-name: "Sat", long-name: "Saturday");
define constant $sunday    :: <day> = make(<day>, short-name: "Sun", long-name: "Sunday");


//// ==== Months

// month-number returns the 1-based month number for the given month.
// January = 1, February = 2, etc.
define sealed generic month-number (m :: <month>) => (n :: <integer>);

// month-long-name returns the long name of the month. "January", "February", etc.
define sealed generic month-long-name (m :: <month>) => (n :: <string>);

// month-short-name returns the 3-letter month name with an initial
// capital letter. "Jan", "Feb", etc.
define sealed generic month-short-name (m :: <month>) => (n :: <string>);

// month-days returns the standard (non-leap year) dayays in the month.
// January = 31, February = 28, etc.
define sealed generic month-days (m :: <month>) => (n :: <integer>);

define sealed class <month> (<object>)
  constant slot month-number :: <integer>,    required-init-keyword: number:;
  constant slot month-long-name :: <string>,  required-init-keyword: long-name:;
  constant slot month-short-name :: <string>, required-init-keyword: short-name:;
  constant slot month-days :: <integer>,      required-init-keyword: days:;
end class;

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
