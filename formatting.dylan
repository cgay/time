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

// Parse a time format string into a sequence of literal strings and formatter
// functions.
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

// Each value is a pair of #(time-component . formatter-function) where
// time-component is the index into the return values list of the
// time-components function. 0 = year, 1 = month, etc
//
// TODO: BC/AD, BCE/CE (see ISO 8601)
// TODO: make this extensible
define table $time-format-map :: <string-table>
  = { "yyyy"   => pair(0, curry(format-ndigit-int, 4)),
      "yy"     => pair(0, curry(format-ndigit-int-mod, 2, 100)),
      "mm"     => pair(1, method (stream, month)
                            format-ndigit-int(2, stream, month.month-number)
                          end),
      "mon"    => pair(1, format-short-month-name),
      "month"  => pair(1, format-long-month-name),
      "dd"     => pair(2, curry(format-ndigit-int, 2)),
      "HH"     => pair(3, curry(format-ndigit-int, 2)),
      "hh"     => pair(3, format-hour-12),
      "am"     => pair(3, format-lowercase-am-pm),
      "pm"     => pair(3, format-lowercase-am-pm),
      "AM"     => pair(3, format-uppercase-am-pm),
      "PM"     => pair(3, format-uppercase-am-pm),
      "MM"     => pair(4, curry(format-ndigit-int, 2)),
      "SS"     => pair(5, curry(format-ndigit-int, 2)),
      "millis" => pair(6, curry(format-ndigit-int-mod, 3, 1000)),
      "micros" => pair(6, curry(format-ndigit-int-mod, 6, 1_000_000)),
      "nanos"  => pair(6, curry(format-ndigit-int-mod, 9, 1_000_000_000)),
      // f = fractional seconds with minimum digits. fN outputs exactly N digits.
      "f"      => pair(6, format-nanos-with-minimum-digits),
      // Not sure if some of these will be used, but might as well be complete.
      "f1"     => pair(6, curry(format-ndigit-int-mod, 1, 10)),
      "f2"     => pair(6, curry(format-ndigit-int-mod, 2, 100)),
      "f3"     => pair(6, curry(format-ndigit-int-mod, 3, 1000)),
      "f4"     => pair(6, curry(format-ndigit-int-mod, 4, 10_000)),
      "f5"     => pair(6, curry(format-ndigit-int-mod, 5, 100_000)),
      "f6"     => pair(6, curry(format-ndigit-int-mod, 6, 1_000_000)),
      "f7"     => pair(6, curry(format-ndigit-int-mod, 7, 10_000_000)),
      "f8"     => pair(6, curry(format-ndigit-int-mod, 8, 100_000_000)),
      "f9"     => pair(6, curry(format-ndigit-int-mod, 9, 1_000_000_000)),

      "zone"     => pair(7, format-zone-name),       // UTC, PST, etc
      "offset"   => pair(7, rcurry(format-zone-offset, colon?: #f, utc-name: #f)), // +0000
      "offset:"  => pair(7, rcurry(format-zone-offset, colon?: #t, utc-name: #f)), // +00:00
      "offset:Z" => pair(7, rcurry(format-zone-offset, colon?: #t, utc-name: "Z")), // Z or +02:00

      "day"     => pair(8, format-short-weekday),
      "weekday" => pair(8, format-long-weekday),
     };

define function format-nanos-with-minimum-digits
    (stream :: <stream>, nanos :: <integer>) => ()
  if (nanos = 0)
    // Since the '.' must be a literal string in the formatter, provided by the
    // user, we need to output something even if nanos are 0.
    write-element(stream, '0');
  else
    // We could do fewer divisions than this. Binary search, essentially.
    iterate loop(n = nanos, i = 9)
      let (q, r) = floor/(n, 10);
      if (r = 0)
        loop(q, i - 1)
      else
        write(stream, integer-to-string(n, size: i));
      end;
    end iterate;
  end;
end function;

define /* inline */ function format-ndigit-int-mod
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

// See RFC 3339 time-zone BNF
define method format-zone-offset
    (stream :: <stream>, zone :: <naive-zone>,
     #key colon? :: <boolean>, utc-name :: <string>?)
 => ()
  let offset = zone-offset(zone);
  if (offset = 0 & utc-name)
    write(stream, utc-name);
  else
    write-element(stream, if (offset < 0) '-' else '+' end);
    let (hour, rem) = truncate/(abs(offset), 3600);
    let (minute, second) = truncate/(rem, 60);
    format-ndigit-int(2, stream, hour);
    if (colon?)
      write-element(stream, ':')
    end;
    format-ndigit-int(2, stream, minute);
    if (second ~= 0)
      if (colon?)
        write-element(stream, ':');
      end;
      format-ndigit-int(2, stream, second);
    end;
  end;
end method;

// TODO: format-zone-offset for <aware-zone>. It needs to receive the reference
// time to calculate the offset.

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

// RFC 3339 format, using the fewest possible digits for fractional seconds.
define constant $rfc3339 :: <time-format>
  = make(<time-format>, string: "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}.{f}{offset:Z}");

// RFC 3339 format, to millisecond precision
define constant $rfc3339-milliseconds :: <time-format>
  = make(<time-format>, string: "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}.{millis}{offset:Z}");

// RFC 3339 format, to microsecond precision
define constant $rfc3339-microseconds :: <time-format>
  = make(<time-format>, string: "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}.{micros}{offset:Z}");

define /* inline */ method format-time
    (stream :: <stream>, fmt :: <time-format>, time :: <time>, #key zone :: <zone>?)
 => ()
  format-time(stream, time-format-parsed(fmt), time, zone: zone);
end method;

// If you care about performance of this formatting, make a <time-format>
// explicitly instead, so it will be parsed only once.
define /* inline */ method format-time
    (stream :: <stream>, fmt :: <string>, time :: <time>, #key zone :: <zone>?)
 => ()
  format-time(stream, parse-time-format(fmt), time, zone: zone);
end method;

define /* inline */ method format-time
    (stream :: <stream>, fmt :: <sequence>, time :: <time>, #key zone :: <zone>?)
 => ()
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




// --- Time parsing ---

define method parse-time
    (input :: <string>, #key format :: <time-format> = $rfc3339, zone :: <zone> = $utc)
 => (time :: <time>)
  // TODO
  time-now()
end method;



// --- Duration formatting ---

define constant $format-duration-short-units
  = vector(pair("w", $week),
           pair("d", $day),
           pair("h", $hour),
           pair("m", $minute),
           pair("s", $second),
           pair("ms", $millisecond),
           pair("u", $microsecond),
           pair("ns", $nanosecond));

define constant $format-duration-long-units
  // Must be ordered largest to smallest.  It happens that these are all
  // regular plurals, and we take advantage of that by adding 's' to the output
  // as necessary. Units smaller than a minute are handled specially.
  = vector(pair("week", $week),
           pair("day", $day),
           pair("hour", $hour),
           pair("minute", $minute));

define method format-duration
    (stream :: <stream>, duration :: <duration>, #key long? :: <boolean>)
 => ()
  let nanos :: <integer> = duration.duration-nanoseconds;
  block (return)
    if (nanos = 0)
      // Choice of seconds as the unit is kind of arbitrary.
      write(stream, if (long?) "0 seconds" else "0s" end);
      return();
    end;
    // TODO: still haven't decided whether durations can be negative. I think
    // not. If they can be negative I should probably use truncate/ not floor/.
    if (nanos < 0)
      nanos := abs(nanos);
      write-element(stream, '-');
    end;
    let did-any-output? = #f;
    local method output (n :: <integer>, unit :: <string>)
            if (long? & did-any-output?) write-element(stream, ' '); end;
            print(n, stream);
            if (long?) write-element(stream, ' ') end;
            write(stream, unit);
            if (long? & n ~= 1) write-element(stream, 's'); end;
            did-any-output? := #t;
          end method,
          method do-units (items :: <sequence>)
            for (item in items)
              let unit :: <string> = item.head;
              let d :: <duration> = item.tail;
              let unit-nanos = d.duration-nanoseconds;
              let n = floor/(nanos, unit-nanos);
              if (n > 0)
                output(n, unit);
                nanos := nanos - (n * unit-nanos);
              end;
            end for;
          end method;
    if (~long?)
      do-units($format-duration-short-units);
      return();
    end;
    do-units($format-duration-long-units);
    // Now just output a decimal number of seconds.
    if (nanos > 0)
      let (seconds, nanos) = floor/(nanos, 1_000_000_000);
      if (did-any-output?) write-element(stream, ' '); end;
      print(seconds, stream);
      iterate loop(n = nanos, i = 9)
        if (n > 0)
          let (q, r) = floor/(n, 10);
          if (r = 0)
            loop(q, i - 1)
          else
            write-element(stream, '.');
            write(stream, integer-to-string(n, size: i));
          end;
        end;
      end iterate;
      write(stream, " seconds");
    end;
  end block;
end method;

// --- Duration parsing ---

// Units have several possible names. See $duration-parsers, below.
//
// * Whitespace is optional.
// * Only integers are allowed.
// * No requirements on order.
// * Case is ignored on input but always output in lowercase.
//
// A ludicrous example: 99w88d77h66m55s44ms33u22n
// A normal example: 90 minutes

define constant $duration-units
  // These are sorted so that any unit name that is a prefix of another occurs
  // AFTER that other. The effect is a greedy parser. Also going with a rough
  // guesstimate as to which units might be used more often and putting them
  // first. Probably more efficient to use a greedy regex and then a table
  // lookup. Or use a <trie> from uncommon-dylan.

  // The singular units here might seem unlikely, but they work with 1: 1 nano,
  // 1 milli, 1 microsecond, ...
  = vector(pair("hours", $hour),
           pair("hour", $hour),
           pair("hrs", $hour),
           pair("hr", $hour),
           pair("h", $hour),

           pair("seconds", $second),
           pair("second", $second),
           pair("sec", $second),
           pair("s", $second),

           pair("milliseconds", $millisecond),
           pair("millisecond", $millisecond),
           pair("millis", $millisecond),
           pair("milli", $millisecond),
           pair("msec", $millisecond),
           pair("ms", $millisecond),

           pair("microseconds", $microsecond),
           pair("microsecond", $microsecond),
           pair("micros", $microsecond),
           pair("micro", $microsecond),
           pair("usec", $microsecond),
           pair("u", $microsecond),

           pair("minutes", $minute),
           pair("minute", $minute),
           pair("min", $minute), 
           pair("m", $minute),  // also prefix of milli and micro

           pair("nanoseconds", $nanosecond),
           pair("nanosecond", $nanosecond),
           pair("nanos", $nanosecond),
           pair("nano", $nanosecond),
           pair("ns", $nanosecond),
           pair("n", $nanosecond),

           pair("days", $day),
           pair("day", $day),
           pair("d", $day),

           pair("weeks", $week),
           pair("week", $week),
           pair("w", $week));

define method parse-duration
    (s :: <string>, #key start :: <integer> = 0, end: _end :: <integer> = s.size)
 => (d :: <duration>, end-position :: <integer>)
  // TODO: pretty inefficient here, in that we go brute force through all
  // possible unit names, longest first. Use a greedy regex or <string-trie>
  // (from uncommon-dylan) instead. Don't necessarily want to create a
  // dependency on either of those libraries though.
  let nanos :: <integer> = 0;
  let index :: <integer> = start;
  local
    method skip-whitespace (bpos :: <integer>) => (epos :: <integer>)
      iterate loop (i = bpos)
        if (i < _end & whitespace?(s[i]))
          loop(i + 1)
        else
          i
        end;
      end;
    end,
    method parse-one (start :: <integer>) => (found? :: <boolean>)
      let bpos = skip-whitespace(start);
      if (bpos < _end)
        let (num, i) = block ()
                         string-to-integer(s, start: bpos, end: _end)
                       exception (<error>)
                         #f
                       end;
        if (num)
          block (done-with-units)
            for (pair in $duration-units)
              let name :: <string> = pair.head;
              let unit :: <duration> = pair.tail;
              i := skip-whitespace(i);
              if (i >= _end)
                done-with-units(#f);
              end;
              if (string-equal-ic?(s, name,
                                   start1: i,
                                   end1: min(_end, i + name.size))
                    // Verify that the following char is either numeric or
                    // whitespace, to prevent e.g. "m" matching "mom".
                    & begin
                        let j = i + name.size;
                        j = _end
                          | decimal-digit?(s[j])
                          | whitespace?(s[j])
                      end)
                nanos := nanos + num * unit.duration-nanoseconds;
                index := i + name.size;
                done-with-units(#t);
              end;
            end for;
            #f
          end block
        end
      end
    end method;
  while (parse-one(index)) end;
  if (index > start)
    // Found at least one spec.
    values(make(<duration>, nanoseconds: nanos), index)
  else
    time-error("no duration found in input at index %d: %=", start, s);
  end
end method;
