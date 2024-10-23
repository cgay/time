Module: time-test-suite

define test test-current-time ()
  let t = time-now();
  assert-true(t.%days >= 18553); // The value when I initially wrote the code.
  assert-true(t.%nanoseconds >= 0 & t.%nanoseconds < 1_000_000_000 * 60 * 60 * 24);
end test;

// TODO: test non-UTC zone
define test test-compose-time ()
  let t1 = compose-time(1970, $january, 1, 0, 0, 0, 0, zone: $utc);
  assert-equal(0, t1.%days);
  assert-equal(0, t1.%nanoseconds);

  let t2 = compose-time(1970, $january, 2, 1, 1, 1, 1, zone: $utc);
  assert-equal(1, t2.%days);
  assert-equal(3_661_000_000_001, t2.%nanoseconds);

  let t3 = compose-time(1969, $december, 31, 0, 0, 0, 1, zone: $utc);
  assert-equal(-1, t3.%days);
  assert-equal(1, t3.%nanoseconds);

  let t4 = compose-time(1969, $december, 31, 23, 59, 59, 999_999_999, zone: $utc);
  assert-equal(-1, t4.%days);
  assert-equal(86_399_999_999_999, t4.%nanoseconds);

  let t5 = compose-time(2020, $october, 18, 0, 0, 0, 0, zone: $utc);
  assert-equal(18553, t5.%days);
  assert-equal(0, t5.%nanoseconds);
end test;

// TODO: test non-UTC zone
define test test-time-components ()
  let t1 = make(<time>, days: 0, nanoseconds: 0);
  let (#rest c1) = time-components(t1, zone: $utc);
  assert-equal(vector(1970, $january, 1, 0, 0, 0, 0, $monday), c1);

  let t2 = make(<time>, days: 1, nanoseconds: 3_661_000_000_001);
  let (#rest c2) = time-components(t2, zone: $utc);
  assert-equal(vector(1970, $january, 2, 1, 1, 1, 1, $monday), c2);

  let t3 = make(<time>, days: -1, nanoseconds: 1);
  let (#rest c3) = time-components(t3, zone: $utc);
  assert-equal(vector(1969, $december, 31, 0, 0, 0, 1, $monday), c3);

  let t4 = make(<time>, days: -1, nanoseconds: 86_399_999_999_999);
  let (#rest c4) = time-components(t4, zone: $utc);
  assert-equal(vector(1969, $december, 31, 23, 59, 59, 999_999_999, $monday), c4);

  let t5 = make(<time>, days: 18553, nanoseconds: 0);
  let (#rest c5) = time-components(t5, zone: $utc);
  assert-equal(vector(2020, $october, 18, 0, 0, 0, 0, $monday), c5);
end test;



define test test-time+duration ()
  let t = $epoch + $nanosecond;
  assert-equal(t.%days, 0);
  assert-equal(t.%nanoseconds, 1);

  let t = $epoch + $hour;
  assert-equal(t.%days, 0);
  assert-equal(t.%nanoseconds, duration-nanoseconds($hour));

  // Add 25h and ensure the day rolls over.
  let t = $epoch + make(<duration>, nanoseconds: 1_000_000_000 * 60 * 60 * 25);
  assert-equal(t.%days, 1);
  assert-equal(t.%nanoseconds, 1_000_000_000 * 60 * 60);

  // Add -25h and ensure the day rolls over.
  let t = $epoch + make(<duration>, nanoseconds: 1_000_000_000 * 60 * 60 * -25);
  assert-equal(t.%days, -2);
  assert-equal(t.%nanoseconds, 1_000_000_000 * 60 * 60 * 23);
end test;

define test test-time-= ()
  // Two times with the same UTC seconds and nanoseconds should be equal.
  let t1 = time-now();
  assert-equal(t1, make(<time>, days: t1.%days, nanoseconds: t1.%nanoseconds));
end test;

define test test-time-< ()
  let t1 = time-now();
  assert-false(t1 < t1);
  assert-false(t1 > t1);

  assert-true(make(<time>, days: 1, nanoseconds: 200) < make(<time>, days: 1, nanoseconds: 300));
  assert-true(make(<time>, days: 1, nanoseconds: 200) < make(<time>, days: 2, nanoseconds: 100));
end test;

define test test-print-object ()
  assert-equal("1970-01-01T00:00:00.0Z", format-to-string("%s", $epoch));
  assert-true(regex-search(compile-regex("{<time> 0d 0ns UTC \\d+}"),
                           format-to-string("%=", $epoch)),
              "%= didn't match the regular expression", $epoch);
end test;
