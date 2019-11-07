Module: time-test

define test test-current-time ()
  let t = current-time();
  assert-equal(t.%seconds, 100);
  assert-equal(t.%nanoseconds, 200);
end;

// Testworks top level
run-test-application();
