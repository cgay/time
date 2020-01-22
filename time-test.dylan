Module: time-test

define test test-current-time ()
  let t = time-now();
  assert-equal(t.%seconds, 100);
  assert-equal(t.%nanoseconds, 200);
  assert-equal($minimum-integer, -9);
  assert-equal($maximum-integer, 9);
end;

// Testworks top level
run-test-application();
