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

define function subzone
    (time, offset, abbrev, dst?) => (_ :: <subzone>)
  make(<subzone>, start-time: time, offset-seconds: offset, abbrev: abbrev, dst?: dst?)
end;

define test test-aware-zone-offsets ()
  assert-no-errors(subzone($epoch, $min-offset-seconds, "min", #t));
  assert-no-errors(subzone($epoch, $max-offset-seconds, "max", #t));
  assert-signals(<time-error>, subzone($epoch, $min-offset-seconds - 1, "min-1", #t));
  assert-signals(<time-error>, subzone($epoch, $max-offset-seconds + 1, "max+1", #t));

  let now = time-now();
  let zone = make(<aware-zone>,
                  name: "Zone",
                  subzones: vector(subzone(now, 100, "EST", #t),
                                   subzone($epoch + $hour, 90, "EST", #t),
                                   subzone($epoch, 80, "EST", #t)));

  // There is no zone info for times before the epoch.
  assert-signals(<time-error>, zone-offset-seconds(zone, time: $epoch - $nanosecond));

  assert-equal(80, zone-offset-seconds(zone, time: $epoch + $minute));
  assert-equal(90, zone-offset-seconds(zone, time: $epoch + 2 * $hour));
  assert-equal(100, zone-offset-seconds(zone, time: now));
  assert-equal(100, zone-offset-seconds(zone)); // uses current time
end test;
