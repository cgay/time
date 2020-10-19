Module: %time
Synopsis: Parsing and formatting times and durations.

// --- Time formatting ---

// Describes a format for outputting a <time>. See $rfc3339 below for an example.
define class <time-format> (<object>)
  constant slot time-format-string :: <string>,
    required-init-keyword: string:;
  constant slot time-format-parsed :: <sequence>,
    init-keyword: parsed:;
end class;


define method make
    (class == <time-format>, #rest args, #key string :: <string>, parsed)
 => (_ :: <time-format>)
  format-out("make(<time-format>, %=\n", args);
  force-out();
  next-method(class,
              string: string,
              parsed: parsed | parse-time-format(string))
end method;

define method print-object
    (fmt :: <time-format>, stream :: <stream>) => ()
  printing-object (fmt, stream)
    write(stream, time-format-string(fmt));
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
      "mm"     => pair(1, method (stream, month)
                            format-ndigit-int(2, stream, month.month-number)
                          end),
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
define /* inline */ function format-ndigit-int-modn
    (digits :: <integer>, mod :: <integer>, stream :: <stream>, n :: <integer>) => ()
  let n :: <integer> = modulo(n, mod);
  write(stream, integer-to-string(n, size: digits, fill: '0'));
end function;

define /* inline */ function format-ndigit-int
    (digits :: <integer>, stream :: <stream>, n :: <integer>) => ()
  write(stream, integer-to-string(n, size: digits, fill: '0'));
end function;

define /* inline */ function format-hour-12
    (stream :: <stream>, hour24 :: <integer>) => ()
  let hour = if (hour24 < 12) hour24 else hour24 - 12 end;
  write(stream, integer-to-string(hour, size: 2, fill: '0'));
end function;

define /* inline */ function format-lowercase-am-pm
    (stream :: <stream>, hour :: <integer>) => ()
  write(stream, if (hour < 12) "am" else "pm" end);
end function;

define /* inline */ function format-uppercase-am-pm
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

define /* inline */ function format-short-weekday
    (stream :: <stream>, day :: <day>) => ()
  write(stream, day.day-short-name);
end function;

define /* inline */ function format-long-weekday
    (stream :: <stream>, day :: <day>) => ()
  write(stream, day.day-long-name);
end function;

define /* inline */ function format-short-month-name
    (stream :: <stream>, month :: <month>) => ()
  write(stream, month.month-short-name);
end function;

define /* inline */ function format-long-month-name
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

define /* inline */ method format-time
    (stream :: <stream>, fmt :: <time-format>, time :: <time>) => ()
  format-time(stream, time-format-parsed(fmt), time);
end method;

// If you care about performance of this formatting, make a <time-format>
// explicitly instead, so it will be parsed only once.
define /* inline */ method format-time
    (stream :: <stream>, fmt :: <string>, time :: <time>) => ()
  format-time(stream, parse-time-format(fmt), time);
end method;

define /* inline */ method format-time
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

define constant $rfc3339 :: <time-format>
  = make(<time-format>, string: "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}{offset}");


// --- Duration formatting ---

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




// --- Time parsing ---

define method parse-time
    (input :: <string>, #key format :: <time-format> = $rfc3339, zone :: <zone> = $utc)
 => (time :: <time>)
  // TODO
  time-now()
end method;

define method parse-duration (s :: <string>) => (d :: <duration>)
  // TODO
  make(<duration>)
end;

