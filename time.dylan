Module: %time

/* TODO

* make %= print something reasonable for all classes.
* 
*/

// Errors explicitly signaled by this library are instances of <time-error>.
define class <time-error> (<error>)
end;


define function time-error(msg :: <string>, #rest format-args)
  error(make(<time-error>,
             format-string: msg,
             format-arguments: format-args));
end;

//// Basic accessors

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

// Make a <time> that represents the same time instant as `t` but in a
// different zone.
define sealed generic time-in-zone (t :: <time>, z :: <zone>) => (t2 :: <time>);
define sealed generic time-in-utc (t :: <time>) => (utc :: <time>);

define sealed generic duration-nanoseconds (d :: <duration>) => (nanoseconds :: <integer>);

//// Conversions

define sealed domain \+ (<duration>, <duration>);
define sealed domain \+ (<time>, <duration>);
define sealed domain \+ (<duration>, <time>);
define sealed domain \- (<duration>, <duration>);
define sealed domain \- (<time>, <duration>);
define sealed domain \* (<duration>, <real>);
define sealed domain \* (<real>, <duration>);
define sealed domain \/ (<duration>, <real>);

define class <time-format> (<object>)
  constant slot time-format-original :: <string>,
    required-init-keyword: original:;
  constant slot time-format-parsed :: <sequence>,
    init-keyword: parsed:;
end class;

define method make
    (class == <time-format>, #key original :: <string>, parsed, #all-keys)
 => (_ :: <time-format>)
  next-method(original: original,
              parsed: parsed | parse-time-format(original))
end method;

define constant $rfc3339
  = make(<time-format>, original: "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}{offset}");

// The choice of {micros} here is a bit arbitrary. It seems like a reasonable compromise?
define constant $rfc3339-precise
  = make(<time-format>, original: "{year}-{mm}-{dd}T{HH}:{MM}:{SS}.{micros}{offset}");

// Parse a time format string into a sequence of literal strings and formatter functions
// like #"four-digit-year".
//
// TODO: there's no way to escape the {} characters if you want those literally
// in the time format. Does it matter?
define function parse-time-format (descriptor :: <string>) => (_ :: <sequence>)
  let len :: <integer> = descriptor.size;
  iterate loop (bpos :: <integer> = 0, epos :: <integer> = 0, parsed :: <list> = #())
    if (epos >= len)
      reverse!(if (bpos < epos)
                 pair(copy-sequence(descriptor, start: bpos), parsed)
               else
                 if (empty?(parsed))
                   time-error("empty formatter string");
                 else
                   parsed
                 end
               end)
    else
      let ch :: <character> = descriptor[epos];
      select (ch)
        '{' => loop(epos + 1,
                    epos + 1,
                    if (bpos < epos)
                      pair(copy-sequence(descriptor, start: bpos, end: epos),
                           parsed)
                    else
                      parsed
                    end);
        '}' => loop(epos + 1,
                    epos + 1,
                    begin
                      let name = copy-sequence(descriptor, start: bpos, end: epos);
                      pair(element($time-format-map, name, default: #f)
                             | time-error("invalid time component specifier: %=", name),
                           parsed)
                    end);
        otherwise =>
          loop(bpos, epos + 1, parsed);
      end select
    end
  end iterate
end function;

// Each value is a pair of #(time-element-index . formatter-function) where
// time-element-index is the index into the return values list of the
// time-components function. 0 = year, 1 = month, etc
//
// TODO: make this extensible
define table $time-format-map :: <string-table>
  = { "yyyy"   => pair(0, curry(format-ndigit-int, 4)),
      "yy"     => pair(0, curry(format-ndigit-int-modn, 2, 100)),
      "mm"     => pair(1, curry(format-ndigit-int, 2)),
      "dd"     => pair(2, curry(format-ndigit-int, 2)),
      "HH"     => pair(3, curry(format-ndigit-int, 2)),
      "hh"     => pair(3, format-hour-12),
      "am"     => pair(3, format-lowercase-am-pm),
      "pm"     => pair(3, format-lowercase-am-pm),
      "AM"     => pair(3, format-uppercase-am-pm),
      "PM"     => pair(3, format-uppercase-am-pm),
      "MM"     => pair(4, curry(format-ndigit-int, 2)),
      "SS"     => pair(5, curry(format-ndigit-int, 2)),
      "ff"     => pair(6, curry(format-ndigit-int-modn, 2, 100)), // 'f' for fraction
      "fff"    => pair(6, curry(format-ndigit-int-modn, 3, 1000)),
      "ffffff" => pair(6, curry(format-ndigit-int-modn, 6, 1_000_000)),
      "fffffffff" => pair(6, curry(format-ndigit-int-modn, 9, 1_000_000_000)),
      "millis" => pair(6, curry(format-ndigit-int-modn, 3, 1000)),
      "micros" => pair(6, curry(format-ndigit-int-modn, 6, 1_000_000)),
      "nanos"  => pair(6, curry(format-ndigit-int-modn, 9, 1_000_000_000)),

      "zone"     => pair(7, format-zone-name),       // UTC, PST, etc
      "offset"   => pair(7, curry(format-zone-offset, /* colon? */ #f, /* Z? */ #f)),   // +0000
      "offset:"  => pair(7, curry(format-zone-offset, /* colon? */ #t, /* Z? */ #f)),  // +00:00
      "offset:Z" => pair(7, curry(format-zone-offset, /* colon? */ #t, /* Z? */ #t)), // Z or +02:00
      "offsetZ:" => pair(7, curry(format-zone-offset, /* colon? */ #t, /* Z? */ #t)), // ditto

      "weekday" => pair(8, format-weekday),
      "month"   => pair(1, format-long-month-name),
      "mon"     => pair(1, format-short-month-name)
        };

define function format-ndigit-int-modn
    (digits :: <integer>, mod :: <integer>, stream :: <stream>, n :: <integer>) => ()
  let n :: <integer> = modulo(n, mod);
  write(stream, integer-to-string(n, size: digits, fill: '0'));
end;

define function format-ndigit-int
    (digits :: <integer>, stream :: <stream>, n :: <integer>) => ()
  write(stream, integer-to-string(n, size: digits, fill: '0'));
end;

// Print `time` on `stream` based on `format`.
define function print-time
    (time :: <time>,
     #key stream :: <stream> = *standard-output*,
          format :: <time-format> = $rfc3339-format)
 => ()
  format-time(stream, format, time);
end;

define sealed generic format-time
    (stream :: <stream>, format :: <object>, time :: <time>) => ();

define inline method format-time
    (stream :: <stream>, fmt :: <time-format>, time :: <time>) => ()
  format-time(stream, time-format-parsed(fmt), time);
end;

define inline method format-time
    (stream :: <stream>, fmt :: <string>, time :: <time>) => ()
  // TODO: memoize fmt
  format-time(stream, parse-time-format(fmt), time);
end;

define inline method format-time
    (stream :: <stream>, fmt :: <sequence>, time :: <time>) => ()
  // I'm assuming that v is stack allocated. Verify.
  let (#rest v) = time-components(time);
  for (item in fmt)
    select (item by instance?)
      <string>
        => write(stream, item);
      <pair>
        => begin
             let index :: <integer> = item.head;
             let formatter :: <function> = item.tail;
             formatter(stream, v[index]);
           end;
      otherwise  => time-error("invalid time format element: %=", item);
    end;
  end;
end method;

define sealed generic parse-time
    (time :: <string>, #key format, zone) => (t :: <time>);

define class <duration-style> (<object>) end;

define constant $duration-heuristic = make(<duration-style>);
define constant $duration-brief = make(<duration-style>);
define constant $duration-long = make(<duration-style>);


// Print `duration` on `stream` based on `style`.
define function print-duration
    (duration :: <duration>,
     #key stream :: <stream> = *standard-output*,
          style :: <duration-style> = $duration-heuristic)
 => ()
  format-duration(stream, style, duration);
end;

define sealed generic format-duration
    (stream :: <stream>, style :: <duration-style>, duration :: <duration>) => ();

define method format-duration
    (stream :: <stream>, style == $duration-heuristic, duration :: <duration>) => ()
  // TODO: I like the way Go outputs durations heuristically.
  write(stream, "123ns");
end;

define sealed generic parse-duration
  (s :: <string>) => (d :: <duration>);

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

// TODO:
// define sealed generic round-time (t :: <time>, d :: <duration>) => (t :: <time>);
// define sealed generic truncate-time (t :: <time>, d :: <duration>) => (t :: <time>);

//// Days

// TODO: do we need day-number => 1..7?
define sealed generic day-full-name (d :: <day>) => (name :: <string>);
define sealed generic day-short-name (d :: <day>) => (name :: <string>);

//// Months

// month-number returns the 1-based month number for the given month.
// January = 1, February = 2, etc.
define sealed generic month-number (m :: <month>) => (n :: <integer>);

// month-full-name returns the full name of the month. "January", "February", etc.
define sealed generic month-full-name (m :: <month>) => (n :: <string>);

// month-short-name returns the 3-letter month name with an initial
// capital letter. "Jan", "Feb", etc.
define sealed generic month-short-name (m :: <month>) => (n :: <string>);

// month-days returns the standard (non-leap year) dayays in the month.
// January = 31, February = 28, etc.
define sealed generic month-days (m :: <month>) => (n :: <integer>);

//// Zones

// The short for the zone, like "UTC" or "CET". If a zone has no short name it
// defaults to the value of zone-offset-string() for the current time. If the
// zone has no offset at the current time it defaults to $unknown-zone-name.
define sealed generic zone-short-name (z :: <zone>) => (name :: <string>);

// The full name for the zone, like "Coordinated Universal Time" or "Central
// European Time". If a zone has no name it defaults to the value of
// zone-offset-string() for the current time. If the zone has no offset at the
// current time it defaults to "???".
define sealed generic zone-full-name (z :: <zone>) => (name :: <string>);

// The number of minutes offset from UTC for zone `z` at time `time`.
// if `time` is not provided it defaults to the current time.
define sealed generic zone-offset (z :: <zone>, #key time) => (minutes :: <integer>);

// Returns a string describing the offset from UTC for zone `z` at time `time`.
// For example, "+0000" for UTC itself or "-0400" for EDT. Use
// `zone-short-name` if you want to display the mnemonic zone name instead. If
// this zone didn't exist at `time` a <time-error> is signaled.
define sealed generic zone-offset-string (z :: <zone>, #key time) => (offset :: <string>);

define constant $unknown-zone-name :: <string> = "???";

define abstract class <zone> (<object>)
  constant slot %short-name :: <string> = $unknown-zone-name, init-keyword: short-name:;
  constant slot %full-name :: <string> = $unknown-zone-name, init-keyword: full-name:;
end class;

define class <naive-time-zone> (<zone>)
  constant slot %offset :: <integer>, required-init-keyword: offset:;
end class;

define class <aware-time-zone> (<zone>)
  // The historical offsets from UTC, ordered newest first because the common
  // case is assumed to be asking about the current time. Each element is a
  // pair(start-time, integer-offset) indicating that at start-time the offset
  // was integer-offset minutes from UTC.  If this zone didn't exist at time
  // `t` a `<time-error>` is signaled.
  //
  // TODO: no idea how often zones change. Need to look at the tz data. It's
  // possible that it's worth using a balanced tree of some sort for this.
  constant slot %offsets :: <sequence>, required-init-keyword: offsets:;
end class;

// TODO: a make method with some error checking of the offsets

define method zone-short-name (z :: <zone>) => (name :: <string>)
  z.%short-name | zone-offset-string(z, time: time-now());
end;

define method zone-full-name (z :: <zone>) => (name :: <string>)
  z.%full-name | zone-offset-string(z, time: time-now());
end;

define constant $utc :: <naive-time-zone>
  = make(<naive-time-zone>,
         full-name: "Coordinated Universal Time",
         short-name: "UTC",
         offset: 0);

define function local-time-zone () => (zone :: <zone>)
  // TODO
  $utc
end;

define method zone-offset
    (z :: <naive-time-zone>, #key time :: false-or(<time>)) => (minutes :: <integer>)
  z.%offset
end method;

define method zone-offset
    (z :: <aware-time-zone>, #key time :: false-or(<time>)) => (minutes :: <integer>)
  let time = time | time-now();
  let offsets = z.%offsets;
  let len :: <integer> = offsets.size;
  iterate loop (i :: <integer> = 0)
    if (i < len)
      let offset = offsets[i];
      let start-time = offset.head;
      if (start-time < time)
        offset.tail
      else
        loop(i + 1)
      end
    else
      time-error("time zone %s has no offset data for time %=", time);
    end
  end iterate
end method;

define method zone-offset-string
    (z :: <zone>, #key time :: false-or(<time>)) => (offset :: <string>)
  let offset = zone-offset(z, time: time);
  let (hours, minutes) = floor/(abs(offset), 60);
  let sign = if (offset < 0) "-" else "+" end;
  format-to-string("%s%02d%02d", sign, hours, round(minutes))
end method;


//// Durations

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

// TODO: could make the <duration> constructor accept nanoseconds of type <duration>
// so that things like 60 * $second can be used. useful? featuritis?

define constant $nanosecond :: <duration>  = make(<duration>, nanoseconds:          1);
define constant $microsecond :: <duration> = make(<duration>, nanoseconds:      1_000);
define constant $millisecond :: <duration> = make(<duration>, nanoseconds:  1_000_000);
define constant $second :: <duration> = make(<duration>, nanoseconds:   1_000_000_000);
define constant $minute :: <duration> = make(<duration>, nanoseconds:  60_000_000_000);
define constant $hour :: <duration> = make(<duration>, nanoseconds: 3_600_000_000_000);
// Is it useful to have idealized $day, $week, etc constants? C++ chrono seems to have them.

define method \= (d1 :: <duration>, d2 :: <duration>) => (equal? :: <boolean>)
  d1.duration-nanoseconds = d2.duration-nanoseconds
end;

// Oof. Heap allocating for these is kind of bad. Value types?

define method \+ (d1 :: <duration>, d2 :: <duration>) => (d :: <duration>)
  make(<duration>, nanoseconds: d1.duration-nanoseconds + d2.duration-nanoseconds)
end;

define method \- (d1 :: <duration>, d2 :: <duration>) => (d :: <duration>)
  make(<duration>, nanoseconds: d1.duration-nanoseconds - d2.duration-nanoseconds)
end;

define method \- (t :: <time>, d :: <duration>) => (d :: <time>)
  let (secs, nanos) = floor/(d.duration-nanoseconds, 1_000_000_000);
  let seconds = t.%seconds - secs;
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
  make(<duration>, nanoseconds: d.duration-nanoseconds * r)
end;

define method \* (r :: <real>, d :: <duration>) => (d :: <duration>)
  d * r
end;

define method parse-duration (s :: <string>) => (d :: <duration>)
  // TODO
  make(<duration>)
end;



define method time-in-zone (t :: <time>, z :: <zone>) => (t2 :: <time>)
  // TODO: stub
  t
end;

define method time-in-utc (t :: <time>) => (utc :: <time>)
  time-in-zone(t, $utc)
end;

define method time-components
    (t :: <time>)
 => (year :: <integer>, month :: <month>, day-of-month :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     nanosecond :: <integer>, zone :: <zone>, day-of-week :: <day>)
  let sec = t.%seconds;
  let time_t = make(<c-time-t*>);
  let year = floor/(sec, 86400 * 365);
  values(0, $january, 0, 0, 0, 0, 0, $utc, $monday)
end;

define method make-time
    (year :: <integer>, month :: <integer>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     #key zone :: <zone> = $utc)
 => (t :: <time>)
  // TODO: stub
  make(<time>)
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
  // This one doesn't need to call time-components since we maintain
  // nanoseconds explicitly.
  t.%nanoseconds
end;


//// Days of the week

define class <day> (<object>)
  constant slot day-full-name :: <string>, required-init-keyword: full-name:;
  constant slot day-short-name :: <string>, required-init-keyword: short-name:;
end;

define constant $monday    :: <day> = make(<day>, short-name: "Mon", full-name: "Monday");
define constant $tuesday   :: <day> = make(<day>, short-name: "Tue", full-name: "Tuesday");
define constant $wednesday :: <day> = make(<day>, short-name: "Wed", full-name: "Wednesday");
define constant $thursday  :: <day> = make(<day>, short-name: "Thu", full-name: "Thursday");
define constant $friday    :: <day> = make(<day>, short-name: "Fri", full-name: "Friday");
define constant $saturday  :: <day> = make(<day>, short-name: "Sat", full-name: "Saturday");
define constant $sunday    :: <day> = make(<day>, short-name: "Sun", full-name: "Sunday");

define method parse-day (name :: <string>) => (d :: <day>)
  element($short-name-to-day, name, default: #f)
    | element($name-to-day, name, default: #f)
    | time-error("%= is not a valid day name", name)
end;

define table $name-to-day :: <case-insensitive-string-table> = {
  $monday.day-full-name    => $monday,
  $tuesday.day-full-name   => $tuesday,
  $wednesday.day-full-name => $wednesday,
  $thursday.day-full-name  => $thursday,
  $friday.day-full-name    => $friday,
  $saturday.day-full-name  => $saturday,
  $sunday.day-full-name    => $sunday
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

define sealed class <month> (<object>)
  constant slot month-number :: <integer>,    required-init-keyword: number:;
  constant slot month-full-name :: <string>,  required-init-keyword: full-name:;
  constant slot month-short-name :: <string>, required-init-keyword: short-name:;
  constant slot month-days :: <integer>,      required-init-keyword: days:;
end;
  
define constant $january :: <month>
  = make(<month>, number:  1, short-name: "Jan", days: 31, full-name: "January");
define constant $february :: <month>
  = make(<month>, number:  2, short-name: "Feb", days: 28, full-name: "February");
define constant $march :: <month>
  = make(<month>, number:  3, short-name: "Mar", days: 31, full-name: "March");
define constant $april :: <month>
  = make(<month>, number:  4, short-name: "Apr", days: 30, full-name: "April");
define constant $may :: <month>
  = make(<month>, number:  5, short-name: "May", days: 31, full-name: "May");
define constant $june :: <month>
  = make(<month>, number:  6, short-name: "Jun", days: 30, full-name: "June");
define constant $july :: <month>
  = make(<month>, number:  7, short-name: "Jul", days: 31, full-name: "July");
define constant $august :: <month>
  = make(<month>, number:  8, short-name: "Aug", days: 31, full-name: "August");
define constant $september :: <month>
  = make(<month>, number:  9, short-name: "Sep", days: 30, full-name: "September");
define constant $october :: <month>
  = make(<month>, number: 10, short-name: "Oct", days: 31, full-name: "October");
define constant $november :: <month>
  = make(<month>, number: 11, short-name: "Nov", days: 30, full-name: "November");
define constant $december :: <month>
  = make(<month>, number: 12, short-name: "Dec", days: 31, full-name: "December");

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
  $january.month-full-name => $january,
  $february.month-full-name => $february,
  $march.month-full-name => $march,
  $april.month-full-name => $april,
  $may.month-full-name => $may,
  $june.month-full-name => $june,
  $july.month-full-name => $july,
  $august.month-full-name => $august,
  $september.month-full-name => $september,
  $october.month-full-name => $october,
  $november.month-full-name => $november,
  $december.month-full-name => $december
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
// For example, time-now(zone: $utc) returns the current UTC time.
//
define function time-now (#key zone :: false-or(<zone>)) => (t :: <time>)
  let spec = make(<timespec*>);
  let result = clock-gettime(get-clock-realtime(), spec);
  make(<time>,
       seconds: spec.timespec-seconds,
       nanoseconds: spec.timespec-nanoseconds)
end;

// A <time> represents an instant in time, to nanosecondd precision. It may
// have a zone associated with it, which affects presentation methods such as
// format-time and time-components. If it has no zone it is a UTC time.
//
// <time> instances are created by calling time-now() or make-time(year, month,
// day, ...), or by adding/subtracting a time and a duration.
//
define class <time> (<object>)
  constant slot %seconds :: <integer> = 0,     init-keyword: seconds:;
  constant slot %nanoseconds :: <integer> = 0, init-keyword: nanoseconds:;
  // TODO: what about not even attaching a zone to a time? All times are UTC
  //       until they are displayed?
  constant slot %zone :: false-or(<zone>) = #f,   init-keyword: zone:;
end;

define constant $epoch :: <time>
  = make(<time>, seconds: 0, nanoseconds: 0, zone: $utc);

define method time-zone (t :: <time>) => (zone :: <zone>)
  t.%zone | $utc
end;


//// Comparisons

define sealed domain \= (<time>, <time>);
define sealed domain \= (<duration>, <duration>);

// Returns true if `t1` and `t2` represent the same time instant. Two
// times can be equal even if they are in different zones. For
// example, 6:00 +0200 CEST and 4:00 UTC are equal.
define method \= (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let utc1 = time-in-utc(t1);
  let utc2 = time-in-utc(t2);
  time-second(utc1) = time-second(utc2)
    & time-nanosecond(utc1) = time-nanosecond(utc2)
end;

define sealed domain \< (<time>, <time>);

define method \< (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let utc1 = time-in-utc(t1);
  let utc2 = time-in-utc(t2);
  let sec1 = time-second(utc1);
  let sec2 = time-second(utc2);
  sec1 < sec2 | (sec1 == sec2 & (time-nanosecond(utc1) < time-nanosecond(utc2)))
end;

define sealed domain \- (<time>, <time>);

define method \- (t1 :: <time>, t2 :: <time>) => (d :: <duration>)
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
end method;
