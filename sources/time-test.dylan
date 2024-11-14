Module: time-test-suite

define test test-current-time ()
  // 20k days since 1970-01-01, the value when I initially wrote the code.
  assert-true(time-now().%microseconds >= 20_000 * $microseconds/day);
end test;

// TODO: test non-UTC zone
define test test-compose-decompose-time ()
  local method comp-decomp (components, expected-microseconds, description)
          let t = apply(compose-time, components);
          expect-equal(expected-microseconds, t.%microseconds, description);
          let (#rest decomp) = decompose-time(t);
          // This removes day-of-week.
          // TODO: fix it and check it. Currently it's always $monday.
          let decomp = copy-sequence(decomp, end: decomp.size - 1);
          expect-equal(components, decomp, description);
        end method;
  comp-decomp(vector(1970, $january, 1, 0, 0, 0, 0), 0, "the epoch");
  comp-decomp(vector(1970, $january, 2, 1, 1, 1, 1),
              $microseconds/day + $microseconds/hour + $microseconds/minute + $microseconds/second + 1,
              "1970-01-02 01:01:01.000001Z");
  comp-decomp(vector(1969, $december, 31, 0, 0, 0, 1),
              -1 * $microseconds/day + 1,
              "1969-12-31 00:00:00.000001Z");
  comp-decomp(vector(1969, $december, 31, 23, 59, 59, 999_999),
              -1 * $microseconds/day
                + 23 * $microseconds/hour
                + 59 * $microseconds/minute
                + 59 * $microseconds/second + 999_999,
              "1969-12-31 23:59:59.999999Z");
  comp-decomp(vector(2020, $october, 18, 0, 0, 0, 0),
              18553 * $microseconds/day,
              "2020-10-18 00:00:00.0Z, a random known day");
end test;

define test test-time-= ()
  // Two times that represent the same UTC instant should be equal, regardless of time
  // zone (if we ever define an <aware-time> with zone in it).
  let t1 = time-now();
  assert-equal(t1, make(<time>, microseconds: t1.%microseconds));
end test;

define test test-time-< ()
  let t1 = time-now();
  assert-false(t1 < t1);
  assert-false(t1 > t1);

  let t2 = make(<time>, microseconds: 200);
  let t3 = make(<time>, microseconds: 300);
  assert-true (t2 < t3);
  assert-false(t3 < t2);

  let t4 = make(<time>, microseconds: -1 * $microseconds/day + 1); // 1 usec into 1969-12-31
  let t5 = make(<time>, microseconds: -1 * $microseconds/day + 2); // 2 usec into 1969-12-31
  assert-true(t4 < t5);
  assert-false(t5 < t4);
  assert-true(t4 < $epoch);
  assert-true(t4 < t2, "a negative time < a positive time?");
end test;

define test test-print-object ()
  assert-equal("1970-01-01T00:00:00.0Z", format-to-string("%s", $epoch));
  assert-true(regex-search(compile-regex(#r"{<time> 1970-01-01T00:00:00.0Z \d+}"),
                           format-to-string("%=", $epoch)),
              "%= didn't match the regular expression", $epoch);
end test;

define test test-minmax-time ()
  expect-equal("-71100-09-30T04:59:46.306048Z",
               format-to-string("%s", $minimum-time));
  expect-equal("75039-04-04T19:00:13.693951Z",
               format-to-string("%s", $maximum-time));
end test;

define test test-days-to-weekday ()
  expect-equal($thursday,  days-to-weekday(7));
  expect-equal($wednesday, days-to-weekday(6));
  expect-equal($tuesday,   days-to-weekday(5));
  expect-equal($monday,    days-to-weekday(4));
  expect-equal($sunday,    days-to-weekday(3));
  expect-equal($saturday,  days-to-weekday(2));
  expect-equal($friday,    days-to-weekday(1));

  expect-equal($thursday,  days-to-weekday(0)); // 1970-01-01 was a Thursday.

  expect-equal($wednesday, days-to-weekday(-1));
  expect-equal($tuesday,   days-to-weekday(-2));
  expect-equal($monday,    days-to-weekday(-3));
  expect-equal($sunday,    days-to-weekday(-4));
  expect-equal($saturday,  days-to-weekday(-5));
  expect-equal($friday,    days-to-weekday(-6));
  expect-equal($thursday,  days-to-weekday(-7));

  for (positive from 0 to 50 by 7,
       negative from 0 to -50 by -7)
    expect-equal($thursday, days-to-weekday(positive));
    expect-equal($thursday, days-to-weekday(negative));
  end;

  expect-equal($friday, days-to-weekday(civil-to-days(2024, 11, 15)));
end test;
