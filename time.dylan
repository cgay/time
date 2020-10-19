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

define method print-object
    (time :: <time>, stream :: <stream>) => ()
  printing-object (time, stream)
    format-time(stream, $rfc3339, time); 
  end;
end method;

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
  printing-object (fmt, stream)
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
  write(stream, zone.zone-name);
end method;

define method format-zone-offset
    (stream :: <stream>, zone :: <naive-zone>,
     #key colon? :: <boolean>,
          utc-name :: <string>?)
 => ()
  let offset = zone-offset(zone);
  if (offset = 0 & utc-name)
    write(stream, utc-name);
  else
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
    (input :: <string>, #key format :: <time-format> = $rfc3339, zone :: <zone> = $utc)
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

// Is it useful to have idealized $day, $week, etc constants? C++ chrono seems
// to have them.

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
  let (days, nanos) = truncate/(d.duration-nanoseconds, $nanos/day);
  let days = t.%days - days;
  let nanos = t.%nanoseconds - nanos;
  if (nanos < 0)
    days := days - 1;
  end;
  make(<time>, days: days, nanoseconds: nanos)
end method;

define method \+ (t :: <time>, d :: <duration>) => (t :: <time>)
  let total-nanos = d.duration-nanoseconds;
  let days = floor/(total-nanos, $nanos/day);
  let nanos = total-nanos - days * $nanos/day;
  let new-days = t.%days + days;
  let new-nanos = t.%nanoseconds + nanos;
  if (abs(new-nanos) >= $nanos/day)
    new-days := new-days + if (new-nanos < 0) -1 else 1 end;
  end;
  make(<time>, days: new-days, nanoseconds: new-nanos)
end method;

define inline method \+ (d :: <duration>, t :: <time>) => (t :: <time>)
  t + d
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


// Returns number of days since civil 1970-01-01.  Negative values indicate
// days prior to 1970-01-01. This directly follows the definition of
// days_from_civil in http://howardhinnant.github.io/date_algorithms.html.
define inline function days-from-civil
    (y :: <integer>, m :: <integer>, d :: <integer>) => (days :: <integer>)
  let y = y - if (m <= 2) 1 else 0 end;
  let era = floor/(if (y >= 0) y else y - 399 end, 400);
  let yoe = y - era * 400;                                         // [0, 399]
  let doy = floor/(153 * (m + (m > 2 & -3 | 9)) + 2, 5) + (d - 1); // [0, 365]
  let doe = yoe * 365 + floor/(yoe, 4) - floor/(yoe, 100) + doy;   // [0, 146096]
  era * 146097 + doe - 719468
end;

define method make-time
    (y :: <integer>, mon :: <month>, d :: <integer>, h :: <integer>,
     min :: <integer>, sec :: <integer>, nano :: <integer>, zone :: <zone>)
 => (_ :: <time>)
  make(<time>,
       days: days-from-civil(y, month-number(mon), d),
       nanoseconds: (h * 60 * 60_000_000_000
                       + min * 60_000_000_000
                       + sec * 1_000_000_000
                       + nano),
       zone: zone)
end method;

// Returns year/month/day triple in civil calendar.  This directly follows the
// definition of civil_from_days in http://howardhinnant.github.io/date_algorithms.html.
define inline function civil-from-days
    (z :: <integer>) => (year :: <integer>, month :: <integer>, day :: <integer>)
  let z = z + 719468;
  let era = floor/(if (z >= 0) z else z - 146096 end, 146097);
  let doe = z - era * 146097;   // [0, 146096]
  let yoe = floor/(doe
                     - floor/(doe, 1460)
                     - floor/(doe, 36524)
                     - floor/(doe, 146096),
                   365);
  let y = yoe + era * 400;
  let doy = doe - (yoe * 365 + floor/(yoe, 4) - floor/(yoe, 100));
  let mp = floor/(doy * 5 + 2, 153);
  let d = doy - floor/(mp * 153 + 2, 5) + 1;
  let m = mp + if (mp < 10) 3 else -9 end;
  values(y + if (m <= 2) 1 else 0 end, m, d)
end function;

// $nanos/day should only be used for durations, which use idealized days.
define constant $nanos/day :: <integer> = 1_000_000_000 * 60 * 60 * 24;
define constant $nanos/hour :: <integer> = 3_600_000_000_000;
define constant $nanos/minute :: <integer> =  60_000_000_000;
define constant $nanos/second :: <integer> =   1_000_000_000;

define method time-components
    (t :: <time>)
 => (y :: <integer>, mon :: <month>, d :: <integer>, h :: <integer>,
     min :: <integer>, sec :: <integer>, nano :: <integer>, zone :: <zone>,
     dow :: <day>)
  // TODO: it would be faster to bit-pack the hour/minute/second/nanos as
  // separate numbers (30+6+6+5=47 bits required) rather than doing all this
  // division.
  let (year, month, day) = civil-from-days(t.%days);
  let month = as(<month>, month);
  let nanos = t.%nanoseconds;
  let hour = floor/(nanos, $nanos/hour);
  nanos := nanos - hour * $nanos/hour;
  let minute = floor/(nanos, $nanos/minute);
  nanos := nanos - minute * $nanos/minute;
  let second = floor/(nanos, $nanos/second);
  let nano = nanos - second * $nanos/second;
  // Note: we return the zone to mirror encode-time.
  values(year, month, day, hour, minute, second, nano, t.%zone,
         // TODO: day of week
         $monday)
end method;

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
       days: floor/(spec.timespec-seconds, 24 * 60 * 60),
       nanoseconds: spec.timespec-nanoseconds * 24 * 60 * 60,
       zone: zone)
end method;

define method time-zone (t :: <time>) => (zone :: <zone>)
  t.%zone
end;


//// Comparisons

// Since zone is used purely for display purposes, it is ignored during
// arithmetic and comparison operations.

// Returns true if `t1` and `t2` represent the same time instant.
define method \= (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  t1.%days = t2.%days
    & t1.%nanoseconds = t2.%nanoseconds
end;

// Returns true if `t1` is before `t2`.
define method \< (t1 :: <time>, t2 :: <time>) => (b :: <boolean>)
  let days1 = t1.%days;
  let days2 = t2.%days;
  days1 < days2 | (days1 == days2 & (t1.%nanoseconds < t2.%nanoseconds))
end;

// Returns the difference between time `t1` and time `t2` as a <duration>,
// which may be negative.
define method \- (t1 :: <time>, t2 :: <time>) => (d :: <duration>)
/*
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
    */
  // TODO
  $nanosecond
end method;
