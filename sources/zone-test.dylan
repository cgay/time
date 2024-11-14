Module: time-test-suite

define test test-naive-zone-offsets ()
  assert-no-errors(make(<naive-zone>, offset-seconds: $min-offset-seconds, name: "min"));
  assert-no-errors(make(<naive-zone>, offset-seconds: $max-offset-seconds, name: "max"));
  assert-signals(<time-error>, make(<naive-zone>, offset-seconds: $min-offset-seconds - 1, name: "min-1"));
  assert-signals(<time-error>, make(<naive-zone>, offset-seconds: $max-offset-seconds + 1, name: "max+1"));

  // Offsets that are an unusual number of seconds are valid.
  assert-no-errors(make(<naive-zone>, offset-seconds: -123, name: "x"));
  assert-no-errors(make(<naive-zone>, offset-seconds: 203, name: "x"));
end test;

define function transition
    (time, offset, abbrev, dst?) => (_ :: <transition>)
  make(<transition>,
       utc-seconds: time.to-utc-seconds,
       offset-seconds: offset,
       abbreviation: abbrev,
       dst?: dst?)
end function;

define test test-aware-zone-offsets ()
  assert-no-errors(transition($epoch, $min-offset-seconds, "min", #t));
  assert-no-errors(transition($epoch, $max-offset-seconds, "max", #t));
  assert-signals(<time-error>, transition($epoch, $min-offset-seconds - 1, "min-1", #t));
  assert-signals(<time-error>, transition($epoch, $max-offset-seconds + 1, "max+1", #t));

  let now = time-now();
  let zone = make(<aware-zone>,
                  name: "Zone",
                  transitions: vector(transition(now, 100, "EST", #t),
                                      transition($epoch + $hour, 90, "EST", #t),
                                      transition($epoch, 80, "EST", #t)));

  assert-equal(80, zone-offset-seconds(zone, time: $epoch + $minute));
  assert-equal(90, zone-offset-seconds(zone, time: $epoch + 2 * $hour));
  assert-equal(100, zone-offset-seconds(zone, time: now));
  assert-equal(100, zone-offset-seconds(zone)); // uses current time
end test;
