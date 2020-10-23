Module: time-test-suite

define constant $nanos/sec = 1_000_000_000;

define constant $one-of-each-unit
  = ($week.duration-nanoseconds
       + $day.duration-nanoseconds
       + $hour.duration-nanoseconds
       + $minute.duration-nanoseconds
       + $second.duration-nanoseconds
       + $millisecond.duration-nanoseconds
       + $microsecond.duration-nanoseconds
       + $nanosecond.duration-nanoseconds);

define test test-parse-duration ()
  let cases
    = list(list("9ns", 9),
           list("3m8s", (3 * 60 + 8) * $nanos/sec),
           list("3m 8s", (3 * 60 + 8) * $nanos/sec),
           list("1w1d1h1m1s1ms1u1ns", $one-of-each-unit),
           list("1w  1d  1h\t1m1s 1ms \t\t  1u1n", $one-of-each-unit),
           list("0h", 0),
           // Exercise each unit at least once.
           list("9n", 9),
           list("9nanos", 9),
           list("9nanosecond", 9),
           list("9 nanoseconds", 9),
           list("9u", 9000),
           list("9 usec", 9000),
           list("9 micro", 9000),
           list("9 micros", 9000),
           list("9 microsecond", 9000),
           list("9 microseconds", 9000),
           list("9ms", 9_000_000),
           list("9msec", 9_000_000),
           list("9milli", 9_000_000),
           list("9millis", 9_000_000),
           list("9 millisecond", 9_000_000),
           list("9milliseconds", 9_000_000),
           list("8s", 8 * $nanos/sec),
           list("8sec", 8 * $nanos/sec),
           list("8second", 8 * $nanos/sec),
           list("8seconds", 8 * $nanos/sec),
           list("7m", 7 * 60 * $nanos/sec),
           list("7min", 7 * 60 * $nanos/sec),
           list("7minute", 7 * 60 * $nanos/sec),
           list("7minutes", 7 * 60 * $nanos/sec),
           list("6h", 6 * 60 * 60 * $nanos/sec),
           list("6hr", 6 * 60 * 60 * $nanos/sec),
           list("6hrs", 6 * 60 * 60 * $nanos/sec),
           list("6hour", 6 * 60 * 60 * $nanos/sec),
           list("6hours", 6 * 60 * 60 * $nanos/sec),
           list("5d", 5 * 24 * 60 * 60 * $nanos/sec),
           list("5day", 5 * 24 * 60 * 60 * $nanos/sec),
           list("5days", 5 * 24 * 60 * 60 * $nanos/sec),
           list("4w", 4 * 7 * 24 * 60 * 60 * $nanos/sec),
           list("4week", 4 * 7 * 24 * 60 * 60 * $nanos/sec),
           list("4weeks", 4 * 7 * 24 * 60 * 60 * $nanos/sec),
           // check start: and end:
           list("22nn", 2, start: 1, end: 3),
           list("c3 million", 3_000_000, start: 1, end: 8),               // 3 milli
           list("c3 million", 3 * 60 * 1_000_000_000, start: 1, end: 4)); // 3 m
  for (item in cases)
    let (input, want, #rest parse-duration-args) = apply(values, item);
    let (got, pos) = apply(parse-duration, input, parse-duration-args);
    assert-equal(want, got.duration-nanoseconds,
                 format-to-string("for input %=, got %=, want %=",
                                  input, got, want));
  end;

  assert-signals(<time-error>, parse-duration("3 million"));
  assert-signals(<time-error>, parse-duration(""));
end test;

define test test-format-duration ()
  let cases
    = list(list("9ns", "0.000000009 seconds", 9),
           list("0s", "0 seconds", 0),
           list("-2ns", "-0.000000002 seconds", -2),
           list("1ns", "0.000000001 seconds", 1),
           list("1w1d1h1m1s1ms1u1ns", "1 week 1 day 1 hour 1 minute 1.001001001 seconds",
                $one-of-each-unit));
  for (item in cases)
    let (want-short, want-long, nanos) = apply(values, item);
    let got-short = with-output-to-string (s)
                      format-duration(s, make(<duration>, nanoseconds: nanos))
                    end;
    let got-long = with-output-to-string (s)
                     format-duration(s, make(<duration>, nanoseconds: nanos), long?: #t)
                   end;
    assert-equal(want-short, got-short,
                 format-to-string("for input %d, got %=, want %=",
                                  nanos, got-short, want-short));
    assert-equal(want-long, got-long,
                 format-to-string("for input %d, got %=, want %=",
                                  nanos, got-long, want-long));
  end;
end test;

define test test-rfc3339-format ()
  assert-equal("1970-01-01T00:00:00.0Z",
               with-output-to-string (s)
                 format-time(s, $rfc3339, $epoch)
               end);
  assert-equal("1970-01-01T00:00:00.000Z",
               with-output-to-string (s)
                 format-time(s, $rfc3339-milliseconds, $epoch)
               end);
  assert-equal("1970-01-01T00:00:00.000000Z",
               with-output-to-string (s)
                 format-time(s, $rfc3339-microseconds, $epoch)
               end);
  // Verify that negative zone offset overflow displays as previous day.
  assert-equal("1969-12-31T19:00:00.000000-05:00",
               with-output-to-string (s)
                 let t = time-in-zone($epoch, make(<naive-zone>, offset: -300, name: "x"));
                 format-time(s, $rfc3339-microseconds, t)
               end);
/*
  // Verify that positive zone offset overflow displays as next day.
  // (Throw in a test for leap day Feb 29 because why not.)
  assert-equal("1969-12-31T19:00:00.000000-05:00",
               with-output-to-string (s)
                 let t = time-in-zone(make-time(2020, 2, 28, 19, 0, 0, 0, 0, $utc),
                                      make(<naive-zone>, offset: 300, name: "x"));
                 format-time(s, $rfc3339-microseconds, t)
               end);
*/
end test;

run-test-application();
