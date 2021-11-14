Module: time-test-suite

// ./junk/tzdb/zdump -V /usr/share/zoneinfo/Hongkong

// TODO: need a way to reference data files from tests in a relative way.
define constant $tzif-test-file = "/usr/share/zoneinfo/Hongkong";

define test test-load-tzif-file ()
  let zone = load-tzif-file(as(<file-locator>, $tzif-test-file));
  assert-equal("HKT", zone.zone-abbreviation);
end test;

define test test-bytes-to-int32 ()
  assert-equal(0, bytes-to-int32(#[0, 0, 0, 0], 0, "test"));
  assert-equal(1, bytes-to-int32(#[0, 0, 0, 1], 0, "test"));
  assert-equal((2 ^ 31) - 1, bytes-to-int32(#[127, 255, 255, 255], 0, "test"));
  assert-equal(-1, bytes-to-int32(#[255, 255, 255, 255], 0, "test"));
  assert-equal(-2, bytes-to-int32(#[255, 255, 255, 254], 0, "test"));
  assert-equal(-(2 ^ 31), bytes-to-int32(#[128, 0, 0, 0], 0, "test"));
end test;

define test test-bytes-to-int64 ()
end test;
