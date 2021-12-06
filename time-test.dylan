Module: time-test-suite

define test test-current-time ()
  let t = time-now();
  assert-true(t.%days >= 18553); // The value when I initially wrote the code.
  assert-true(t.%nanoseconds >= 0 & t.%nanoseconds < 1_000_000_000 * 60 * 60 * 24);
end test;

define constant $components-test-cases
  = list(list(list(1970, $january, 1, 0, 0, 0, 0, $utc, $monday),
              list(0, 0)),
         list(list(1970, $january, 2, 1, 1, 1, 1, $utc, $monday),
              list(1, 3_661_000_000_001)),
         list(list(1969, $december, 31, 0, 0, 0, 1, $utc, $monday),
              list(-1, 1)),
         list(list(1969, $december, 31, 23, 59, 59, 999_999_999, $utc, $monday),
              list(-1, 86_399_999_999_999)),
         list(list(2020, $october, 18, 0, 0, 0, 0, $utc, $monday),
              list(18553, 0)));

define test test-compose-time ()
  for (tc in $components-test-cases)
    let (args, want) = apply(values, tc);
    let args = copy-sequence(args, end: args.size - 1); // remove the day
    let t = apply(compose-time, args);
    let (want-days, want-nanos) = apply(values, want);
    assert-equal(t.%days, want-days,
                 format-to-string("for %= got days %=, want %=",
                                  args, t.%days, want-days));
    assert-equal(t.%nanoseconds, want-nanos,
                 format-to-string("for %= got nanoseconds %=, want %=",
                                  args, t.%nanoseconds, want-nanos));
  end;
end test;

define test test-time-components ()
  for (tc in $components-test-cases)
    let (args, want) = apply(values, reverse(tc));
    let t = make(<time>, days: args[0], nanoseconds: args[1]);
    let (#rest got) = time-components(t);
    assert-equal(got, want,
                 format-to-string("for %= got %=, want %=", args, got, want));
  end;
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
  let t1 = time-now();
  assert-equal(t1, make(<time>, days: t1.%days, nanoseconds: t1.%nanoseconds));

  // Two times with the same UTC seconds and nanoseconds should be equal
  // regardless of zone.
  assert-equal(make(<time>, days: 1, nanoseconds: 1, zone: $utc),
               make(<time>, days: 1, nanoseconds: 1,
                    zone: make(<naive-zone>, name: "x", offset-seconds: 5 * 60 * 60)));
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
  assert-equal("{<time> 0d 0ns +00:00}", format-to-string("%=", $epoch));
end test;
