Module: time-test-suite

define test test-current-time ()
  let t = time-now();
  assert-true(t.%seconds > 1579722183); // The value when I initially wrote the code.
  assert-true(t.%nanoseconds >= 0 & t.%nanoseconds < 1_000_000_000);
end test;

run-test-application();
