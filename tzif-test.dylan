Module: time-test-suite

// ./junk/tzdb/zdump -V /usr/share/zoneinfo/Hongkong

// TODO: need a way to reference data files from tests in a relative way.
// Do it with dylan-tool, relative to workspace directory.
define constant $tzif-test-file = "/usr/share/zoneinfo/Hongkong";

define test test-load-tzif-file ()
  let zone = load-tzif-file(as(<file-locator>, $tzif-test-file), debug?: #t);
  assert-equal("HKT", zone.zone-abbreviation);
end test;

define test test-bytes-to-int32 ()
  assert-equal(0, bytes-to-int32(#[0, 0, 0, 0]));
  assert-equal(1, bytes-to-int32(#[0, 0, 0, 1]));
  assert-equal(2147483647, bytes-to-int32(#[127, 255, 255, 255]));
  assert-equal(-1, bytes-to-int32(#[255, 255, 255, 255]));
  assert-equal(-2, bytes-to-int32(#[255, 255, 255, 254]));
  assert-equal(-2147483648, bytes-to-int32(#[128, 0, 0, 0]));
end test;

define test test-bytes-to-int64 ()
  assert-equal(0, bytes-to-int32(#[0, 0, 0, 0]));
  assert-equal(1, bytes-to-int32(#[0, 0, 0, 1]));
  assert-equal(2147483647, bytes-to-int32(#[127, 255, 255, 255]));
  assert-equal(-1, bytes-to-int32(#[255, 255, 255, 255]));
  assert-equal(-2, bytes-to-int32(#[255, 255, 255, 254]));
  assert-equal(-2147483648, bytes-to-int32(#[128, 0, 0, 0]));
end test;
