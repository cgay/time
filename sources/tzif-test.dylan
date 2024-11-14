Module: time-test-suite

// We currently have no way to reference data files from our tests, so I've encoded the
// data below instead.

// --- Example data files from RFC 9636. ---

// Example B.1.  Version 1 File Representing UTC (with Leap Seconds)
// https://datatracker.ietf.org/doc/html/rfc9636#appendix-B.1
define constant $version-1-example-bytes
  = as(<byte-vector>,
       #[#x54, #x5a, #x69, #x66, //     magic   "TZif"
         #x00,                   //     version 0 (1)
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, // unused (15)
         #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x01, //     isutcnt 1
         #x00, #x00, #x00, #x01, //     isstdcnt 1
         #x00, #x00, #x00, #x1b, //     leapcnt 27
         #x00, #x00, #x00, #x00, //     timecnt 0
         #x00, #x00, #x00, #x01, //     typecnt 1
         #x00, #x00, #x00, #x04, //     charcnt 4
         // localtimetype[0]
         #x00, #x00, #x00, #x00, //     utoff   0 (+00:00)
         #x00,                   //     isdst   0 (no)
         #x00,                   //     desigidx 0
         #x55, #x54, #x43, #x00, //     designations[0] "UTC\0"
         // leapsecond[0]
         #x04, #xb2, #x58, #x00, //     occurrence      78796800 (1972-06-30T23:59:60Z)
         #x00, #x00, #x00, #x01, //     correction      1
         // leapsecond[1]
         #x05, #xa4, #xec, #x01, //     occurrence      94694401 (1972-12-31T23:59:60Z)
         #x00, #x00, #x00, #x02, //     correction      2
         // leapsecond[2]
         #x07, #x86, #x1f, #x82, //     occurrence      126230402 (1973-12-31T23:59:60Z)
         #x00, #x00, #x00, #x03, //     correction      3
         // leapsecond[3]
         #x09, #x67, #x53, #x03, //     occurrence      157766403 (1974-12-31T23:59:60Z)
         #x00, #x00, #x00, #x04, //     correction      4
         // leapsecond[4]
         #x0b, #x48, #x86, #x84, //     occurrence      189302404 (1975-12-31T23:59:60Z)
         #x00, #x00, #x00, #x05, //     correction      5
         // leapsecond[5]
         #x0d, #x2b, #x0b, #x85, //     occurrence      220924805 (1976-12-31T23:59:60Z)
         #x00, #x00, #x00, #x06, //     correction      6
         // leapsecond[6]
         #x0f, #x0c, #x3f, #x06, //     occurrence      252460806 (1977-12-31T23:59:60Z)
         #x00, #x00, #x00, #x07, //     correction      7
         // leapsecond[7]
         #x10, #xed, #x72, #x87, //     occurrence      283996807 (1978-12-31T23:59:60Z)
         #x00, #x00, #x00, #x08, //     correction      8
         // leapsecond[8]
         #x12, #xce, #xa6, #x08, //     occurrence      315532808 (1979-12-31T23:59:60Z)
         #x00, #x00, #x00, #x09, //     correction      9
         // leapsecond[9]
         #x15, #x9f, #xca, #x89, //     occurrence      362793609 (1981-06-30T23:59:60Z)
         #x00, #x00, #x00, #x0a, //     correction      10
         // leapsecond[10]
         #x17, #x80, #xfe, #x0a, //     occurrence      394329610 (1982-06-30T23:59:60Z)
         #x00, #x00, #x00, #x0b, //     correction      11
         // leapsecond[11]
         #x19, #x62, #x31, #x8b, //     occurrence      425865611 (1983-06-30T23:59:60Z)
         #x00, #x00, #x00, #x0c, //     correction      12
         // leapsecond[12]
         #x1d, #x25, #xea, #x0c, //     occurrence      489024012 (1985-06-30T23:59:60Z)
         #x00, #x00, #x00, #x0d, //     correction      13
         // leapsecond[13]
         #x21, #xda, #xe5, #x0d, //     occurrence      567993613 (1987-12-31T23:59:60Z)
         #x00, #x00, #x00, #x0e, //     correction      14
         // leapsecond[14]
         #x25, #x9e, #x9d, #x8e, //     occurrence      631152014 (1989-12-31T23:59:60Z)
         #x00, #x00, #x00, #x0f, //     correction      15
         // leapsecond[15]
         #x27, #x7f, #xd1, #x0f, //     occurrence      662688015 (1990-12-31T23:59:60Z)
         #x00, #x00, #x00, #x10, //     correction      16
         // leapsecond[16]
         #x2a, #x50, #xf5, #x90, //     occurrence      709948816 (1992-06-30T23:59:60Z)
         #x00, #x00, #x00, #x11, //     correction      17
         // leapsecond[17]
         #x2c, #x32, #x29, #x11, //     occurrence      741484817 (1993-06-30T23:59:60Z)
         #x00, #x00, #x00, #x12, //     correction      18
         // leapsecond[18]
         #x2e, #x13, #x5c, #x92, //     occurrence      773020818 (1994-06-30T23:59:60Z)
         #x00, #x00, #x00, #x13, //     correction      19
         // leapsecond[19]
         #x30, #xe7, #x24, #x13, //     occurrence      820454419 (1995-12-31T23:59:60Z)
         #x00, #x00, #x00, #x14, //     correction      20
         // leapsecond[20]
         #x33, #xb8, #x48, #x94, //     occurrence      867715220 (1997-06-30T23:59:60Z)
         #x00, #x00, #x00, #x15, //     correction      21
         // leapsecond[21]
         #x36, #x8c, #x10, #x15, //     occurrence      915148821 (1998-12-31T23:59:60Z)
         #x00, #x00, #x00, #x16, //     correction      22
         // leapsecond[22]
         #x43, #xb7, #x1b, #x96, //     occurrence      1136073622 (2005-12-31T23:59:60Z)
         #x00, #x00, #x00, #x17, //     correction      23
         // leapsecond[23]
         #x49, #x5c, #x07, #x97, //     occurrence      1230768023 (2008-12-31T23:59:60Z)
         #x00, #x00, #x00, #x18, //     correction      24
         // leapsecond[24]
         #x4f, #xef, #x93, #x18, //     occurrence      1341100824 (2012-06-30T23:59:60Z)
         #x00, #x00, #x00, #x19, //     correction      25
         // leapsecond[25]
         #x55, #x93, #x2d, #x99, //     occurrence      1435708825 (2015-06-30T23:59:60Z)
         #x00, #x00, #x00, #x1a, //     correction      26
         // leapsecond[26]
         #x58, #x68, #x46, #x9a, //     occurrence      1483228826 (2016-12-31T23:59:60Z)
         #x00, #x00, #x00, #x1b, //     correction      27
         #x00,                   //     standard/wall[0]        0 (wall)
         #x00]);                 //     UT/local[0]             0 (local)

define test test-load-tzif-version-1 ()
  let tzif = make(<tzif>,
                  name: "UTC",
                  data: $version-1-example-bytes,
                  source: "$version-1-example-bytes");
  let zone = load-zone(tzif);   // mutates tzif
  expect-equal(1, tzif.%version);
  expect-equal(272, tzif.%end-of-v1-data);
  expect-equal(-1, tzif.%end-of-v2-data); // no v2+ data
  expect-equal(1, tzif.%is-utc-count);
  expect-equal(1, tzif.%is-std-count);
  expect-equal(27, tzif.%leap-count);
  expect-equal(0, tzif.%time-count);
  expect-equal(1, tzif.%type-count);
  expect-equal(4, tzif.%char-count);
  expect-equal(0, zone.%transitions.size);
  // TODO: check leap second data
end test;

// Example B.2.  Version 2 File Representing Pacific/Honolulu
define constant $version-2-example-bytes
  = as(<byte-vector>,
       #[#x54, #x5a, #x69, #x66, //     magic   "TZif"
         #x32,                   //     version '2' (2)
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, // unused (15)
         #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x06, //     isutcnt 6
         #x00, #x00, #x00, #x06, //     isstdcnt        6
         #x00, #x00, #x00, #x00, //     leapcnt 0
         #x00, #x00, #x00, #x07, //     timecnt 7
         #x00, #x00, #x00, #x06, //     typecnt 6
         #x00, #x00, #x00, #x14, //     charcnt 20
         #x80, #x00, #x00, #x00, //     trans time[0]   -2147483648 (1901-12-13T20:45:52Z)
         #xbb, #x05, #x43, #x48, //     trans time[1]   -1157283000 (1933-04-30T12:30:00Z)
         #xbb, #x21, #x71, #x58, //     trans time[2]   -1155436200 (1933-05-21T21:30:00Z)
         #xcb, #x89, #x3d, #xc8, //     trans time[3]   -880198200 (1942-02-09T12:30:00Z)
         #xd2, #x23, #xf4, #x70, //     trans time[4]   -769395600 (1945-08-14T23:00:00Z)
         #xd2, #x61, #x49, #x38, //     trans time[5]   -765376200 (1945-09-30T11:30:00Z)
         #xd5, #x8d, #x73, #x48, //     trans time[6]   -712150200 (1947-06-08T12:30:00Z)
         #x01,                   //     trans type[0]   1
         #x02,                   //     trans type[1]   2
         #x01,                   //     trans type[2]   1
         #x03,                   //     trans type[3]   3
         #x04,                   //     trans type[4]   4
         #x01,                   //     trans type[5]   1
         #x05,                   //     trans type[6]   5
         // localtimetype[0]
         #xff, #xff, #x6c, #x02, //     utoff   -37886 (-10:31:26)
         #x00,                   //     isdst   0 (no)
         #x00,                   //     desigidx        0
         // localtimetype[1]
         #xff, #xff, #x6c, #x58, //     utoff   -37800 (-10:30)
         #x00,                   //     isdst   0 (no)
         #x04,                   //     desigidx        4
         // localtimetype[2]
         #xff, #xff, #x7a, #x68, //     utoff   -34200 (-09:30)
         #x01,                   //     isdst   1 (yes)
         #x08,                   //     desigidx        8
         // localtimetype[3]
         #xff, #xff, #x7a, #x68, //     utoff   -34200 (-09:30)
         #x01,                   //     isdst   1 (yes)
         #x0c,                   //     desigidx        12
         // localtimetype[4]
         #xff, #xff, #x7a, #x68, //     utoff   -34200 (-09:30)
         #x01,                   //     isdst   1 (yes)
         #x10,                   //     desigidx        16
         // localtimetype[5]
         #xff, #xff, #x73, #x60, //     utoff   -36000 (-10:00)
         #x00,                   //     isdst   0 (no)
         #x04,                   //     desigidx        4
         #x4c, #x4d, #x54, #x00, //     designations[0] "LMT\0"
         #x48, #x53, #x54, #x00, //     designations[4] "HST\0"
         #x48, #x44, #x54, #x00, //     designations[8] "HDT\0"
         #x48, #x57, #x54, #x00, //     designations[12]        "HWT\0"
         #x48, #x50, #x54, #x00, //     designations[16]        "HPT\0"
         #x00,                   //     standard/wall[0]        0 (wall)
         #x00,                   //     standard/wall[1]        0 (wall)
         #x00,                   //     standard/wall[2]        0 (wall)
         #x00,                   //     standard/wall[3]        0 (wall)
         #x01,                   //     standard/wall[4]        1 (standard)
         #x00,                   //     standard/wall[5]        0 (wall)
         #x00,                   //     UT/local[0]     0 (local)
         #x00,                   //     UT/local[1]     0 (local)
         #x00,                   //     UT/local[2]     0 (local)
         #x00,                   //     UT/local[3]     0 (local)
         #x01,                   //     UT/local[4]     1 (UT)
         #x00,                   //     UT/local[5]     0 (local)
         #x54, #x5a, #x69, #x66, //     magic   "TZif"
         #x32,                   //     version '2' (2)
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x06, //     isutcnt 6
         #x00, #x00, #x00, #x06, //     isstdcnt        6
         #x00, #x00, #x00, #x00, //     leapcnt 0
         #x00, #x00, #x00, #x07, //     timecnt 7
         #x00, #x00, #x00, #x06, //     typecnt 6
         #x00, #x00, #x00, #x14, //     charcnt 20
         #xff, #xff, #xff, #xff, #x74, #xe0, #x70, #xbe, // trans time[0]   -2334101314 (1896-01-13T22:31:26Z)
         #xff, #xff, #xff, #xff, #xbb, #x05, #x43, #x48, // trans time[1]   -1157283000 (1933-04-30T12:30:00Z)
         #xff, #xff, #xff, #xff, #xbb, #x21, #x71, #x58, // trans time[2]   -1155436200 (1933-05-21T21:30:00Z)
         #xff, #xff, #xff, #xff, #xcb, #x89, #x3d, #xc8, // trans time[3]   -880198200 (1942-02-09T12:30:00Z)
         #xff, #xff, #xff, #xff, #xd2, #x23, #xf4, #x70, // trans time[4]   -769395600 (1945-08-14T23:00:00Z)
         #xff, #xff, #xff, #xff, #xd2, #x61, #x49, #x38, // trans time[5]   -765376200 (1945-09-30T11:30:00Z)
         #xff, #xff, #xff, #xff, #xd5, #x8d, #x73, #x48, // trans time[6]   -712150200 (1947-06-08T12:30:00Z)
         #x01,                   //     trans type[0]   1
         #x02,                   //     trans type[1]   2
         #x01,                   //     trans type[2]   1
         #x03,                   //     trans type[3]   3
         #x04,                   //     trans type[4]   4
         #x01,                   //     trans type[5]   1
         #x05,                   //     trans type[6]   5
         // localtimetype[0]
         #xff, #xff, #x6c, #x02, //     utoff   -37886 (-10:31:26)
         #x00,                   //     isdst   0 (no)
         #x00,                   //     desigidx        0
         // localtimetype[1]
         #xff, #xff, #x6c, #x58, //     utoff   -37800 (-10:30)
         #x00,                   //     isdst   0 (no)
         #x04,                   //     desigidx        4
         // localtimetype[2]
         #xff, #xff, #x7a, #x68, //     utoff   -34200 (-09:30)
         #x01,                   //     isdst   1 (yes)
         #x08,                   //     desigidx        8
         // localtimetype[3]
         #xff, #xff, #x7a, #x68, //     utoff   -34200 (-09:30)
         #x01,                   //     isdst   1 (yes)
         #x0c,                   //     desigidx        12
         // localtimetype[4]
         #xff, #xff, #x7a, #x68, //     utoff   -34200 (-09:30)
         #x01,                   //     isdst   1 (yes)
         #x10,                   //     desigidx        16
         // localtimetype[5]
         #xff, #xff, #x73, #x60, //     utoff   -36000 (-10:00)
         #x00,                   //     isdst   0 (no)
         #x04,                   //     desigidx        4
         #x4c, #x4d, #x54, #x00, //     designations[0] "LMT\0"
         #x48, #x53, #x54, #x00, //     designations[4] "HST\0"
         #x48, #x44, #x54, #x00, //     designations[8] "HDT\0"
         #x48, #x57, #x54, #x00, //     designations[12]        "HWT\0"
         #x48, #x50, #x54, #x00, //     designations[16]        "HPT\0"
         #x00,                   //     standard/wall[0]        0 (wall)
         #x00,                   //     standard/wall[1]        0 (wall)
         #x00,                   //     standard/wall[2]        0 (wall)
         #x00,                   //     standard/wall[3]        0 (wall)
         #x01,                   //     standard/wall[4]        1 (standard)
         #x00,                   //     standard/wall[5]        0 (wall)
         #x00,                   //     UT/local[0]     0 (local)
         #x00,                   //     UT/local[1]     0 (local)
         #x00,                   //     UT/local[2]     0 (local)
         #x00,                   //     UT/local[3]     0 (local)
         #x01,                   //     UT/local[4]     1 (UT)
         #x00,                   //     UT/local[5]     0 (local)
         #x0a,                   //     NL      '\n'
         #x48, #x53, #x54, #x31, #x30, //  TZ string       "HST10"
         #x0a]);                 //     NL      '\n'

define test test-load-tzif-version-2 ()
  // Note that even though the B.2 example has valid version 1 data we don't test it
  // because we ignore v1 data in v2+ files.
  let tzif = make(<tzif>,
                  name: "Pacific/Honolulu",
                  data: $version-2-example-bytes,
                  source: "$version-2-example-bytes");
  let zone = load-zone(tzif);
  expect-equal(2, tzif.%version);
  expect-equal(147, tzif.%end-of-v1-data);
  expect-equal(322, tzif.%end-of-v2-data);
  expect-equal(6, tzif.%is-utc-count);
  expect-equal(6, tzif.%is-std-count);
  expect-equal(0, tzif.%leap-count);
  expect-equal(7, tzif.%time-count);
  expect-equal(6, tzif.%type-count);
  expect-equal(20, tzif.%char-count);
  expect-equal(7, zone.%transitions.size);
  // Remember, the transitions are reversed...
  expect-equal(-2334101314, zone.%transitions[6].%utc-seconds); // 1896-01-13T22:31:26Z
  expect-equal(-712150200, zone.%transitions[0].%utc-seconds);  // 1947-06-08T12:30:00Z
end test;

// Example B.3.  Truncated Version 3 File Representing Asia/Jerusalem
// https://datatracker.ietf.org/doc/html/rfc9636#appendix-B.3
define constant $version-3-example-bytes
  = as(<byte-vector>,
       #[#x54, #x5A, #x69, #x66, // magic "TZif"
         #x33,                   // version '3' (3)
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, // unused (15)
         #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, // isutcnt 0
         #x00, #x00, #x00, #x00, // isstdcnt 0
         #x00, #x00, #x00, #x00, // leapcnt 0
         #x00, #x00, #x00, #x00, // timecnt 0
         #x00, #x00, #x00, #x01, // typecnt 1
         #x00, #x00, #x00, #x01, // charcnt 1
         // localtimetype[0]
         #x00, #x00, #x00, #x00, // utoff   0 (+00:00)
         #x00,                   // isdst   0 (no)
         #x00,                   // desigidx        0
         #x00,                   // designations[0] "\0"
         #x54, #x5a, #x69, #x66, // magic   "TZif"
         #x33,                   // version '3' (3)
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, // isutcnt 0
         #x00, #x00, #x00, #x00, // isstdcnt 0
         #x00, #x00, #x00, #x00, // leapcnt 0
         #x00, #x00, #x00, #x01, // timecnt 1
         #x00, #x00, #x00, #x02, // typecnt 2
         #x00, #x00, #x00, #x08, // charcnt 8
         // trans time[0]   2145916800 (2038-01-01T00:00:00Z)
         #x00, #x00, #x00, #x00, #x7f, #xe8, #x17, #x80,
         #x01,                   // trans type[0]   1
         // localtimetype[0]
         #x00, #x00, #x00, #x00, // utoff   0 (+00:00)
         #x00,                   // isdst   0 (no)
         #x00,                   // desigidx 0
         // localtimetype[1]
         #x00, #x00, #x1c, #x20, // utoff   7200 (+02:00)
         #x00,                   // isdst   0 (no)
         #x04,                   // desigidx 4
         #x2d, #x30, #x30, #x00, // designations[0] "-00\0"
         #x49, #x53, #x54, #x00, // designations[4] "IST\0"
         #x0a,                   // NL      '\n'
         // TZ string "IST-2IDT,M3.4.4/26,M10.5.0"
         #x49, #x53, #x54, #x2d, #x32, #x49, #x44, #x54,
         #x2c, #x4d, #x33, #x2e, #x34, #x2e, #x34, #x2f,
         #x32, #x36, #x2c, #x4d, #x31, #x30, #x2e, #x35,
         #x2e, #x30,
         #x0a]);                // NL      '\n'

define test test-load-tzif-version-3 ()
  let tzif = make(<tzif>,
                  name: "Asia/Jerusalem",
                  data: $version-3-example-bytes,
                  source: "$version-3-example-bytes");
  let zone = load-zone(tzif);
  expect-equal(3, tzif.%version);
  expect-equal(51, tzif.%end-of-v1-data);
  expect-equal(124, tzif.%end-of-v2-data);
  expect-equal(0, tzif.%is-utc-count);
  expect-equal(0, tzif.%is-std-count);
  expect-equal(0, tzif.%leap-count);
  expect-equal(1, tzif.%time-count);
  expect-equal(2, tzif.%type-count);
  expect-equal(8, tzif.%char-count);
  expect-equal(1, zone.%transitions.size);
  expect-equal(2145916800,      // 2038-01-01T00:00:00Z
               zone.%transitions[0].%utc-seconds);
  // TODO: footer
end test;


// From /usr/share/zoneinfo/Hongkong on Debian 4.19.171-2
define constant $linux-hongkong-tzif-bytes
  = as(<byte-vector>,
       #[#x54, #x5a, #x69, #x66, #x32, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x07, #x00, #x00, #x00, #x07, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x46, #x00, #x00, #x00, #x07, #x00, #x00, #x00, #x16, #x80, #x00, #x00, #x00,
         #x85, #x69, #x63, #x90, #xca, #x4d, #x31, #x30, #xca, #xdb, #x93, #x30, #xcb, #x4b, #x71, #x78,
         #xd2, #xa0, #xde, #x90, #xd3, #x6b, #xd7, #x80, #xd4, #x93, #x58, #xb8, #xd5, #x42, #xb0, #x38,
         #xd6, #x73, #x3a, #xb8, #xd7, #x3e, #x41, #xb8, #xd8, #x2e, #x32, #xb8, #xd8, #xf9, #x39, #xb8,
         #xda, #x0e, #x14, #xb8, #xda, #xd9, #x1b, #xb8, #xdb, #xed, #xf6, #xb8, #xdc, #xb8, #xfd, #xb8,
         #xdd, #xcd, #xd8, #xb8, #xde, #xa2, #x1a, #x38, #xdf, #xb6, #xf5, #x38, #xe0, #x81, #xfc, #x38,
         #xe1, #x96, #xc9, #x28, #xe2, #x4f, #x69, #x38, #xe3, #x76, #xab, #x28, #xe4, #x2f, #x4b, #x38,
         #xe5, #x5f, #xc7, #xa8, #xe6, #x0f, #x2d, #x38, #xe7, #x3f, #xa9, #xa8, #xe7, #xf8, #x49, #xb8,
         #xe9, #x1f, #x8b, #xa8, #xe9, #xd8, #x2b, #xb8, #xea, #xff, #x6d, #xa8, #xeb, #xb8, #x0d, #xb8,
         #xec, #xdf, #x4f, #xa8, #xed, #x97, #xef, #xb8, #xee, #xc8, #x6c, #x28, #xef, #x77, #xd1, #xb8,
         #xf0, #xa8, #x4e, #x28, #xf1, #x57, #xb3, #xb8, #xf2, #x88, #x30, #x28, #xf3, #x40, #xd0, #x38,
         #xf4, #x68, #x12, #x28, #xf5, #x20, #xb2, #x38, #xf6, #x47, #xf4, #x28, #xf7, #x25, #x7e, #x38,
         #xf8, #x15, #x61, #x28, #xf9, #x05, #x60, #x38, #xf9, #xf5, #x43, #x28, #xfa, #xe5, #x42, #x38,
         #xfb, #xde, #x5f, #xa8, #xfc, #xce, #x5e, #xb8, #xfd, #xbe, #x41, #xa8, #xfe, #xae, #x40, #xb8,
         #xff, #x9e, #x23, #xa8, #x00, #x8e, #x22, #xb8, #x01, #x7e, #x05, #xa8, #x02, #x6e, #x04, #xb8,
         #x03, #x5d, #xe7, #xa8, #x04, #x4d, #xe6, #xb8, #x05, #x47, #x04, #x28, #x06, #x37, #x03, #x38,
         #x07, #x26, #xe6, #x28, #x07, #x83, #x3d, #x38, #x09, #x06, #xc8, #x28, #x09, #xf6, #xc7, #x38,
         #x0a, #xe6, #xaa, #x28, #x0b, #xd6, #xa9, #x38, #x0c, #xc6, #x8c, #x28, #x11, #x9b, #x39, #x38,
         #x12, #x6f, #x6c, #xa8, #x00, #x01, #x02, #x03, #x04, #x01, #x02, #x05, #x06, #x05, #x06, #x05,
         #x02, #x05, #x02, #x05, #x02, #x05, #x02, #x05, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01,
         #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01,
         #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01,
         #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x00, #x00, #x6b, #x0a, #x00, #x00,
         #x00, #x00, #x70, #x80, #x00, #x04, #x00, #x00, #x7e, #x90, #x01, #x08, #x00, #x00, #x77, #x88,
         #x01, #x0d, #x00, #x00, #x7e, #x90, #x00, #x12, #x00, #x00, #x70, #x80, #x00, #x04, #x00, #x00,
         #x7e, #x90, #x01, #x08, #x4c, #x4d, #x54, #x00, #x48, #x4b, #x54, #x00, #x48, #x4b, #x53, #x54,
         #x00, #x48, #x4b, #x57, #x54, #x00, #x4a, #x53, #x54, #x00, #x00, #x00, #x00, #x00, #x00, #x01,
         #x01, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x54, #x5a, #x69, #x66, #x32, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x07,
         #x00, #x00, #x00, #x07, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x46, #x00, #x00, #x00, #x07,
         #x00, #x00, #x00, #x16, #xf8, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #xff, #xff, #xff, #xff,
         #x85, #x69, #x63, #x90, #xff, #xff, #xff, #xff, #xca, #x4d, #x31, #x30, #xff, #xff, #xff, #xff,
         #xca, #xdb, #x93, #x30, #xff, #xff, #xff, #xff, #xcb, #x4b, #x71, #x78, #xff, #xff, #xff, #xff,
         #xd2, #xa0, #xde, #x90, #xff, #xff, #xff, #xff, #xd3, #x6b, #xd7, #x80, #xff, #xff, #xff, #xff,
         #xd4, #x93, #x58, #xb8, #xff, #xff, #xff, #xff, #xd5, #x42, #xb0, #x38, #xff, #xff, #xff, #xff,
         #xd6, #x73, #x3a, #xb8, #xff, #xff, #xff, #xff, #xd7, #x3e, #x41, #xb8, #xff, #xff, #xff, #xff,
         #xd8, #x2e, #x32, #xb8, #xff, #xff, #xff, #xff, #xd8, #xf9, #x39, #xb8, #xff, #xff, #xff, #xff,
         #xda, #x0e, #x14, #xb8, #xff, #xff, #xff, #xff, #xda, #xd9, #x1b, #xb8, #xff, #xff, #xff, #xff,
         #xdb, #xed, #xf6, #xb8, #xff, #xff, #xff, #xff, #xdc, #xb8, #xfd, #xb8, #xff, #xff, #xff, #xff,
         #xdd, #xcd, #xd8, #xb8, #xff, #xff, #xff, #xff, #xde, #xa2, #x1a, #x38, #xff, #xff, #xff, #xff,
         #xdf, #xb6, #xf5, #x38, #xff, #xff, #xff, #xff, #xe0, #x81, #xfc, #x38, #xff, #xff, #xff, #xff,
         #xe1, #x96, #xc9, #x28, #xff, #xff, #xff, #xff, #xe2, #x4f, #x69, #x38, #xff, #xff, #xff, #xff,
         #xe3, #x76, #xab, #x28, #xff, #xff, #xff, #xff, #xe4, #x2f, #x4b, #x38, #xff, #xff, #xff, #xff,
         #xe5, #x5f, #xc7, #xa8, #xff, #xff, #xff, #xff, #xe6, #x0f, #x2d, #x38, #xff, #xff, #xff, #xff,
         #xe7, #x3f, #xa9, #xa8, #xff, #xff, #xff, #xff, #xe7, #xf8, #x49, #xb8, #xff, #xff, #xff, #xff,
         #xe9, #x1f, #x8b, #xa8, #xff, #xff, #xff, #xff, #xe9, #xd8, #x2b, #xb8, #xff, #xff, #xff, #xff,
         #xea, #xff, #x6d, #xa8, #xff, #xff, #xff, #xff, #xeb, #xb8, #x0d, #xb8, #xff, #xff, #xff, #xff,
         #xec, #xdf, #x4f, #xa8, #xff, #xff, #xff, #xff, #xed, #x97, #xef, #xb8, #xff, #xff, #xff, #xff,
         #xee, #xc8, #x6c, #x28, #xff, #xff, #xff, #xff, #xef, #x77, #xd1, #xb8, #xff, #xff, #xff, #xff,
         #xf0, #xa8, #x4e, #x28, #xff, #xff, #xff, #xff, #xf1, #x57, #xb3, #xb8, #xff, #xff, #xff, #xff,
         #xf2, #x88, #x30, #x28, #xff, #xff, #xff, #xff, #xf3, #x40, #xd0, #x38, #xff, #xff, #xff, #xff,
         #xf4, #x68, #x12, #x28, #xff, #xff, #xff, #xff, #xf5, #x20, #xb2, #x38, #xff, #xff, #xff, #xff,
         #xf6, #x47, #xf4, #x28, #xff, #xff, #xff, #xff, #xf7, #x25, #x7e, #x38, #xff, #xff, #xff, #xff,
         #xf8, #x15, #x61, #x28, #xff, #xff, #xff, #xff, #xf9, #x05, #x60, #x38, #xff, #xff, #xff, #xff,
         #xf9, #xf5, #x43, #x28, #xff, #xff, #xff, #xff, #xfa, #xe5, #x42, #x38, #xff, #xff, #xff, #xff,
         #xfb, #xde, #x5f, #xa8, #xff, #xff, #xff, #xff, #xfc, #xce, #x5e, #xb8, #xff, #xff, #xff, #xff,
         #xfd, #xbe, #x41, #xa8, #xff, #xff, #xff, #xff, #xfe, #xae, #x40, #xb8, #xff, #xff, #xff, #xff,
         #xff, #x9e, #x23, #xa8, #x00, #x00, #x00, #x00, #x00, #x8e, #x22, #xb8, #x00, #x00, #x00, #x00,
         #x01, #x7e, #x05, #xa8, #x00, #x00, #x00, #x00, #x02, #x6e, #x04, #xb8, #x00, #x00, #x00, #x00,
         #x03, #x5d, #xe7, #xa8, #x00, #x00, #x00, #x00, #x04, #x4d, #xe6, #xb8, #x00, #x00, #x00, #x00,
         #x05, #x47, #x04, #x28, #x00, #x00, #x00, #x00, #x06, #x37, #x03, #x38, #x00, #x00, #x00, #x00,
         #x07, #x26, #xe6, #x28, #x00, #x00, #x00, #x00, #x07, #x83, #x3d, #x38, #x00, #x00, #x00, #x00,
         #x09, #x06, #xc8, #x28, #x00, #x00, #x00, #x00, #x09, #xf6, #xc7, #x38, #x00, #x00, #x00, #x00,
         #x0a, #xe6, #xaa, #x28, #x00, #x00, #x00, #x00, #x0b, #xd6, #xa9, #x38, #x00, #x00, #x00, #x00,
         #x0c, #xc6, #x8c, #x28, #x00, #x00, #x00, #x00, #x11, #x9b, #x39, #x38, #x00, #x00, #x00, #x00,
         #x12, #x6f, #x6c, #xa8, #x00, #x01, #x02, #x03, #x04, #x01, #x02, #x05, #x06, #x05, #x06, #x05,
         #x02, #x05, #x02, #x05, #x02, #x05, #x02, #x05, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01,
         #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01,
         #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01,
         #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x02, #x01, #x00, #x00, #x6b, #x0a, #x00, #x00,
         #x00, #x00, #x70, #x80, #x00, #x04, #x00, #x00, #x7e, #x90, #x01, #x08, #x00, #x00, #x77, #x88,
         #x01, #x0d, #x00, #x00, #x7e, #x90, #x00, #x12, #x00, #x00, #x70, #x80, #x00, #x04, #x00, #x00,
         #x7e, #x90, #x01, #x08, #x4c, #x4d, #x54, #x00, #x48, #x4b, #x54, #x00, #x48, #x4b, #x53, #x54,
         #x00, #x48, #x4b, #x57, #x54, #x00, #x4a, #x53, #x54, #x00, #x00, #x00, #x00, #x00, #x00, #x01,
         #x01, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x0a, #x48, #x4b, #x54, #x2d, #x38, #x0a]);

define test test-load-tzif-file ()
  // Create the file
  let path = merge-locators(as(<file-locator>, "Hongkong"), test-temp-directory());
  with-open-file (stream = path, direction: #"output", element-type: <byte>)
    for (byte in $linux-hongkong-tzif-bytes)
      write-element(stream, byte);
    end;
  end;
  let zone = load-tzif-file("Hongkong", path);
  assert-equal("HKT", zone.zone-abbreviation);
  // TODO: more validation
end test;

define test test-load-zone-data ()
  assert-no-errors(load-all-zones());
end;

define test test-bytes-to-int32 ()
  assert-equal(0, bytes-to-int32(#[0, 0, 0, 0], 0, "test"));
  assert-equal(1, bytes-to-int32(#[0, 0, 0, 1], 0, "test"));
  assert-equal(3, bytes-to-int32(#[0, 0, 0, 3], 0, "test"));
  assert-equal((2 ^ 31) - 1, bytes-to-int32(#[127, 255, 255, 255], 0, "test"));
  assert-equal(-1, bytes-to-int32(#[255, 255, 255, 255], 0, "test"));
  assert-equal(-2, bytes-to-int32(#[255, 255, 255, 254], 0, "test"));
  assert-equal(-(2 ^ 31), bytes-to-int32(#[128, 0, 0, 0], 0, "test"));
end test;

define test test-bytes-to-int64 ()
  assert-equal(0, bytes-to-int64(#[0, 0, 0, 0, 0, 0, 0, 0], 0, "test"));
  assert-equal(1, bytes-to-int64(#[0, 0, 0, 0, 0, 0, 0, 1], 0, "test"));
  assert-equal(ga/-(ga/^(2, 63), 1),
               bytes-to-int64(#[127, 255, 255, 255, 255, 255, 255, 255], 0, "test"));
  assert-equal(-1, bytes-to-int64(#[255, 255, 255, 255, 255, 255, 255, 255], 0, "test"));
  assert-equal(-2, bytes-to-int64(#[255, 255, 255, 255, 255, 255, 255, 254], 0, "test"));
  assert-equal(ga/^(-2, 63),
               bytes-to-int64(#[128, 0, 0, 0, 0, 0, 0, 0], 0, "test"));
end test;

// Just a couple of checks that my own TZ is working correctly.
define test test-us-eastern-sanity-check (expected-to-fail-reason: "aware zones not finished")
  let us-eastern :: <aware-zone> = find-zone("US/Eastern");

  // {<transition> EST o=-18000 dst=#f 2021-11-07T06:00:00.0Z...}
  // {<transition> EDT o=-14400 dst=#t 2021-03-14T07:00:00.0Z...}

  // From US/Eastern TZif file according to zdump.py:
  // 2021-03-14 07:00:00 UTC = 2021-03-14 03:00:00 EDT   isdst=1 +1

  // At 2021-03-14T06:59:59.999999999Z is it still EST?
  let t1 = compose-time(2021, $march, 14, 6, 59, 59, 999_999_999);
  assert-equal(-5 * 60 * 60, zone-offset-seconds(us-eastern, time: t1));

  // At 2021-03-14T07:00:00.0Z (one nano later) has it switched to EDT?
  let t2 = compose-time(2021, $march, 14, 2, 0, 0, 0);
  //assert-equal(-4 * 60 * 60, zone-offset-seconds(us-eastern, time: t2));
  let utc-string
    = with-output-to-string (s1)
        format(s1, "x");
        format-time(s1, "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}.{micros}{offset}", t2,
                    zone: $utc)
      end;
  test-output("bbb\n");
  let us-eastern-string
    = with-output-to-string (s2)
        format-time(s2, "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}.{micros}{offset}", t2,
                    zone: us-eastern)
      end;
  test-output("ccc\n");

  assert-equal(utc-string, us-eastern-string);

  // At 2021-11-07T05:59:59.999999999Z is it still EDT?
  let t3 = compose-time(2021, $november, 7, 5, 59, 59, 999_999_999);
  assert-equal(-4 * 60 * 60, zone-offset-seconds(us-eastern, time: t3));

  // At 2021-11-07T06:00:00.0Z (one nano later) has it switched back to EST?
  let t4 = compose-time(2021, $november, 7, 6, 0, 0, 0);
  assert-equal(-5 * 60 * 60, zone-offset-seconds(us-eastern, time: t4));
end test;
