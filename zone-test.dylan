Module: time-test-suite

define test test-naive-zone-offsets ()
  // Largest current positive offset
  assert-no-errors(make(<naive-zone>, offset: 14 * 60, name: "Kiribati"));

  // Largest current negative offset
  assert-no-errors(make(<naive-zone>, offset: -12 * 60, name: "Howland Island"));

  // Offsets that are an unusual number of minutes are valid.
  assert-no-errors(make(<naive-zone>, offset: -123, name: "x"));
  assert-no-errors(make(<naive-zone>, offset: 203, name: "x"));

  // Offsets that are wildly too big (e.g., accidentally specifying seconds).
  assert-signals(<time-error>, make(<naive-zone>, offset: 24 * 60, name: "x"));
  assert-signals(<time-error>, make(<naive-zone>, offset: -24 * 60, name: "x"));
end test;

define function subzone
    (time, offset, abbrev, dst?) => (_ :: <subzone>)
  make(<subzone>, start-time: time, offset: offset, abbrev: abbrev, dst?: dst?)
end;

define test test-aware-zone-offsets ()
  let sub = subzone($epoch, 24 * 60, "ABC", #t);  // +24h is too big.
  assert-signals(<time-error>,
                 make(<aware-zone>, name: "x", subzones: vector(sub)));

  let sub = subzone($epoch, -24 * 60, "ABC", #t); // -24h is too big.
  assert-signals(<time-error>,
                 make(<aware-zone>, name: "x", subzones: vector(sub)));

  let now = time-now();
  let zone = make(<aware-zone>,
                  name: "Zone",
                  subzones: vector(subzone(now, 180, "EST", #t),
                                   subzone($epoch + $hour, 120, "EST", #t),
                                   subzone($epoch, 60, "EST", #t)));

  // There is no zone info for times before the epoch.
  assert-signals(<time-error>, zone-offset(zone, time: $epoch - $nanosecond));

  assert-equal(60, zone-offset(zone, time: $epoch + $minute));
  assert-equal(120, zone-offset(zone, time: $epoch + 2 * $hour));
  assert-equal(180, zone-offset(zone, time: now));
  assert-equal(180, zone-offset(zone)); // uses current time
end test;
