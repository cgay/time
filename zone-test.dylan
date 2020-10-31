Module: time-test-suite

define test test-naive-zone-offsets ()
  assert-no-errors(make(<naive-zone>, offset: $min-offset, name: "min"));
  assert-no-errors(make(<naive-zone>, offset: $max-offset, name: "max"));
  assert-signals(<time-error>, make(<naive-zone>, offset: $min-offset - 1, name: "min-1"));
  assert-signals(<time-error>, make(<naive-zone>, offset: $max-offset + 1, name: "max+1"));

  // Offsets that are an unusual number of seconds are valid.
  assert-no-errors(make(<naive-zone>, offset: -123, name: "x"));
  assert-no-errors(make(<naive-zone>, offset: 203, name: "x"));
end test;

define function subzone
    (time, offset, abbrev, dst?) => (_ :: <subzone>)
  make(<subzone>, start-time: time, offset: offset, abbrev: abbrev, dst?: dst?)
end;

define test test-aware-zone-offsets ()
  assert-no-errors(subzone($epoch, $min-offset, "min", #t));
  assert-no-errors(subzone($epoch, $max-offset, "max", #t));
  assert-signals(<time-error>, subzone($epoch, $min-offset - 1, "min-1", #t));
  assert-signals(<time-error>, subzone($epoch, $max-offset + 1, "max+1", #t));

  let now = time-now();
  let zone = make(<aware-zone>,
                  name: "Zone",
                  subzones: vector(subzone(now, 100, "EST", #t),
                                   subzone($epoch + $hour, 90, "EST", #t),
                                   subzone($epoch, 80, "EST", #t)));

  // There is no zone info for times before the epoch.
  assert-signals(<time-error>, zone-offset(zone, time: $epoch - $nanosecond));

  assert-equal(80, zone-offset(zone, time: $epoch + $minute));
  assert-equal(90, zone-offset(zone, time: $epoch + 2 * $hour));
  assert-equal(100, zone-offset(zone, time: now));
  assert-equal(100, zone-offset(zone)); // uses current time
end test;
