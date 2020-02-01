Module: %time
Synopsis: Time and duration implementations (because they're somewhat intertwined)

/* TODO

* make %= print something reasonable for all classes.

*/

define function time-error(msg :: <string>, #rest format-args)
  error(make(<time-error>,
             format-string: msg,
             format-arguments: format-args));
end;


// Time formats

// <time-format>s are used for both printing and parsing.

define method make
    (class == <time-format>, #key original :: <string>, parsed, #all-keys)
 => (_ :: <time-format>)
  next-method(original: original,
              parsed: parsed | parse-time-format(original))
end method;

define method print-object
    (fmt :: <time-format>, stream :: <stream>) => ()
  printing-logical-block (stream, prefix: "<time-format ", suffix: ">")
    write(stream, time-format-original(fmt));
  end;
end method;

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
      "offset"   => pair(7, rcurry(format-zone-offset, colon?: #f, utc-name: #f)), // +0000
      "offset:"  => pair(7, rcurry(format-zone-offset, colon?: #t, utc-name: #f)), // +00:00
      "offset:Z" => pair(7, rcurry(format-zone-offset, colon?: #t, utc-name: "Z")), // Z or +02:00
      "offsetZ:" => pair(7, rcurry(format-zone-offset, colon?: #t, utc-name: "Z")), // ditto

      "day"     => pair(8, format-short-weekday),
      "weekday" => pair(8, format-long-weekday),
      "mon"     => pair(1, format-short-month-name),
      "month"   => pair(1, format-long-month-name)
        };

// TODO: ...-modn name is confusing with n parameter.
define inline function format-ndigit-int-modn
    (digits :: <integer>, mod :: <integer>, stream :: <stream>, n :: <integer>) => ()
  let n :: <integer> = modulo(n, mod);
  write(stream, integer-to-string(n, size: digits, fill: '0'));
end function;

define inline function format-ndigit-int
    (digits :: <integer>, stream :: <stream>, n :: <integer>) => ()
  write(stream, integer-to-string(n, size: digits, fill: '0'));
end function;

define inline function format-hour-12
    (stream :: <stream>, hour24 :: <integer>) => ()
  let hour = if (hour24 < 12) hour24 else hour24 - 12 end;
  write(stream, integer-to-string(hour, size: 2, fill: '0'));
end function;

define inline function format-lowercase-am-pm
    (stream :: <stream>, hour :: <integer>) => ()
  write(stream, if (hour < 12) "am" else "pm" end);
end function;

define inline function format-uppercase-am-pm
    (stream :: <stream>, hour :: <integer>) => ()
  write(stream, if (hour < 12) "AM" else "PM" end);
end function;

define method format-zone-name
    (stream :: <stream>, zone :: <naive-zone>)
  format-zone-offset(stream, zone);
end method;

define method format-zone-name
    (stream :: <stream>, zone :: <aware-zone>)
  // TODO: just showing offset until tzdata parsed
  format-zone-offset(stream, zone)
end method;

define method format-zone-offset
    (stream :: <stream>, zone :: <naive-zone>,
     #key colon? :: <boolean>,
          utc-name :: false-or(<string>))
 => ()
  let offset = zone-offset(zone);
  if (offset = 0 & utc-name)
    write(stream, utc-name);
  else
    // TODO: deal with seconds in offset (rare, but possible, RFC3339)
    let offset-minutes = truncate/(abs(offset), 60);
    
    write(stream, if (offset-minutes < 0) "-" else "+" end);
    let (hour, minute) = truncate/(offset-minutes, 60);
    format-ndigit-int(2, stream, hour);
    format-ndigit-int(2, stream, minute);
  end;
end method;

define inline function format-short-weekday
    (stream :: <stream>, day :: <day>) => ()
  write(stream, day.day-short-name);
end function;

define inline function format-long-weekday
    (stream :: <stream>, day :: <day>) => ()
  write(stream, day.day-long-name);
end function;

define inline function format-short-month-name
    (stream :: <stream>, month :: <month>) => ()
  write(stream, month.month-short-name);
end function;

define inline function format-long-month-name
    (stream :: <stream>, month :: <month>) => ()
  write(stream, month.month-long-name);
end function;

// Print `time` on `stream` based on `format`.
define method print-time
    (time :: <time>,
     #key stream :: <stream> = *standard-output*,
          format :: <time-format> = $rfc3339)
 => ()
  format-time(stream, format, time);
end method;

define inline method format-time
    (stream :: <stream>, fmt :: <time-format>, time :: <time>) => ()
  format-time(stream, time-format-parsed(fmt), time);
end method;

define inline method format-time
    (stream :: <stream>, fmt :: <string>, time :: <time>) => ()
  // TODO: memoize fmt
  format-time(stream, parse-time-format(fmt), time);
end method;

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


// ==== Time parsing

define method parse-time
    (input :: <string>, #key format :: false-or(<time-format>), zone :: <zone> = $utc)
 => (time :: <time>)
  // TODO
  time-now()
end method;


// ==== Duration formats

define abstract class <duration-format> (<object>) end;

define class <duration-short-format> (<duration-format>) end;
define class <duration-long-format> (<duration-format>) end;

define constant $duration-short-format = make(<duration-short-format>);
define constant $duration-long-format = make(<duration-long-format>);

define method print-duration
    (duration :: <duration>,
     #key stream :: <stream> = *standard-output*,
          format :: <duration-format> = $duration-short-format,
          precision :: <duration> = $nanosecond)
 => ()
  format-duration(stream, format, duration, precision: precision);
end method;

define method format-duration
    (stream :: <stream>, format :: <string>, duration :: <duration>,
     #key precision :: <duration> = $nanosecond)
 => ()
  // TODO: parse `format` and cache it
  write(stream, "456n");
end method;

define method format-duration
    (stream :: <stream>, format :: <duration-short-format>, duration :: <duration>,
     #key precision :: <duration> = $nanosecond)
 => ()
  // TODO: I like the way Go outputs durations heuristically.
  write(stream, "123ns");
end;

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

define inline-only method \* (r :: <real>, d :: <duration>) => (d :: <duration>)
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
    (year :: <integer>, month :: <month>, day :: <integer>,
     hour :: <integer>, minute :: <integer>, second :: <integer>,
     #key nanosecond :: <integer> = 0,
          zone :: <zone> = $utc)
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


// ===== Months

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

// Returns the current time in the local time zone, or in `zone` if supplied.
// For example, time-now(zone: $utc) returns the current UTC time.
//
define method time-now (#key zone :: <zone> = local-time-zone()) => (t :: <time>)
  let spec = make(<timespec*>);
  let result = clock-gettime(get-clock-realtime(), spec);
  make(<time>,
       seconds: spec.timespec-seconds,
       nanoseconds: spec.timespec-nanoseconds,
       zone: zone)
end method;

define method time-zone (t :: <time>) => (zone :: <zone>)
  t.%zone | $utc
end;


//// Comparisons

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


// For `<aware-zone>` different
// names may be returned depending whether the time represents an instant in
// daylight savings time in that zone or not. For example, if `time` represents
// 2019-03-10T06:59Z and its zone is "North America/New York" then
// zone-short-name returns "EST" (UTC-5) but c
define method zone-abbreviation (time :: <time>) => (abbrev :: <string>)

