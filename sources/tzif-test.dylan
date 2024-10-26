Module: time-test-suite

// We currently have no way to reference data files from our tests, so I've encoded the
// data below instead.

// --- Example data files from RFC 8536. ---

// Example B.1.  Version 1 File Representing UTC (with Leap Seconds)
define constant $version-1-example-bytes
  = as(<byte-vector>,
       #[#x54, #x5a, #x69, #x66, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x01, #x00, #x00, #x00, #x01, #x00, #x00, #x00, #x1b,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x01, #x00, #x00, #x00, #x04, #x00, #x00, #x00, #x00,
         #x00, #x00, #x55, #x54, #x43, #x00, #x04, #xb2, #x58, #x00, #x00, #x00, #x00, #x01, #x05, #xa4,
         #xec, #x01, #x00, #x00, #x00, #x02, #x07, #x86, #x1f, #x82, #x00, #x00, #x00, #x03, #x09, #x67,
         #x53, #x03, #x00, #x00, #x00, #x04, #x0b, #x48, #x86, #x84, #x00, #x00, #x00, #x05, #x0d, #x2b,
         #x0b, #x85, #x00, #x00, #x00, #x06, #x0f, #x0c, #x3f, #x06, #x00, #x00, #x00, #x07, #x10, #xed,
         #x72, #x87, #x00, #x00, #x00, #x08, #x12, #xce, #xa6, #x08, #x00, #x00, #x00, #x09, #x15, #x9f,
         #xca, #x89, #x00, #x00, #x00, #x0a, #x17, #x80, #xfe, #x0a, #x00, #x00, #x00, #x0b, #x19, #x62,
         #x31, #x8b, #x00, #x00, #x00, #x0c, #x1d, #x25, #xea, #x0c, #x00, #x00, #x00, #x0d, #x21, #xda,
         #xe5, #x0d, #x00, #x00, #x00, #x0e, #x25, #x9e, #x9d, #x8e, #x00, #x00, #x00, #x0f, #x27, #x7f,
         #xd1, #x0f, #x00, #x00, #x00, #x10, #x2a, #x50, #xf5, #x90, #x00, #x00, #x00, #x11, #x2c, #x32,
         #x29, #x11, #x00, #x00, #x00, #x12, #x2e, #x13, #x5c, #x92, #x00, #x00, #x00, #x13, #x30, #xe7,
         #x24, #x13, #x00, #x00, #x00, #x14, #x33, #xb8, #x48, #x94, #x00, #x00, #x00, #x15, #x36, #x8c,
         #x10, #x15, #x00, #x00, #x00, #x16, #x43, #xb7, #x1b, #x96, #x00, #x00, #x00, #x17, #x49, #x5c,
         #x07, #x97, #x00, #x00, #x00, #x18, #x4f, #xef, #x93, #x18, #x00, #x00, #x00, #x19, #x55, #x93,
         #x2d, #x99, #x00, #x00, #x00, #x1a, #x58, #x68, #x46, #x9a, #x00, #x00, #x00, #x1b, #x00, #x00]);

// Example B.2.  Version 2 File Representing Pacific/Honolulu
define constant $version-2-example-bytes
  = as(<byte-vector>,
       #[#x54, #x5a, #x69, #x66, #x32, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x06, #x00, #x00, #x00, #x06, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x07, #x00, #x00, #x00, #x06, #x00, #x00, #x00, #x14, #x80, #x00, #x00, #x00,
         #xbb, #x05, #x43, #x48, #xbb, #x21, #x71, #x58, #xcb, #x89, #x3d, #xc8, #xd2, #x23, #xf4, #x70,
         #xd2, #x61, #x49, #x38, #xd5, #x8d, #x73, #x48, #x01, #x02, #x01, #x03, #x04, #x01, #x05, #xff,
         #xff, #x6c, #x02, #x00, #x00, #xff, #xff, #x6c, #x58, #x00, #x04, #xff, #xff, #x7a, #x68, #x01,
         #x08, #xff, #xff, #x7a, #x68, #x01, #x0c, #xff, #xff, #x7a, #x68, #x01, #x10, #xff, #xff, #x73,
         #x60, #x00, #x04, #x4c, #x4d, #x54, #x00, #x48, #x53, #x54, #x00, #x48, #x44, #x54, #x00, #x48,
         #x57, #x54, #x00, #x48, #x50, #x54, #x00, #x00, #x00, #x00, #x00, #x01, #x00, #x00, #x00, #x00,
         #x00, #x01, #x00, #x54, #x5a, #x69, #x66, #x32, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x06, #x00, #x00, #x00, #x06, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x07, #x00, #x00, #x00, #x06, #x00, #x00, #x00, #x14, #xff,
         #xff, #xff, #xff, #x74, #xe0, #x70, #xbe, #xff, #xff, #xff, #xff, #xbb, #x05, #x43, #x48, #xff,
         #xff, #xff, #xff, #xbb, #x21, #x71, #x58, #xff, #xff, #xff, #xff, #xcb, #x89, #x3d, #xc8, #xff,
         #xff, #xff, #xff, #xd2, #x23, #xf4, #x70, #xff, #xff, #xff, #xff, #xd2, #x61, #x49, #x38, #xff,
         #xff, #xff, #xff, #xd5, #x8d, #x73, #x48, #x01, #x02, #x01, #x03, #x04, #x01, #x05, #xff, #xff,
         #x6c, #x02, #x00, #x00, #xff, #xff, #x6c, #x58, #x00, #x04, #xff, #xff, #x7a, #x68, #x01, #x08,
         #xff, #xff, #x7a, #x68, #x01, #x0c, #xff, #xff, #x7a, #x68, #x01, #x10, #xff, #xff, #x73, #x60,
         #x00, #x04, #x4c, #x4d, #x54, #x00, #x48, #x53, #x54, #x00, #x48, #x44, #x54, #x00, #x48, #x57,
         #x54, #x00, #x48, #x50, #x54, #x00, #x00, #x00, #x00, #x00, #x01, #x00, #x00, #x00, #x00, #x00,
         #x01, #x00, #x0a, #x48, #x53, #x54, #x31, #x30, #x0a]);

// Example B.3.  Truncated Version 3 File Representing Asia/Jerusalem
// Note that the values in the v2 header, starting at byte 064, are incorrect in the RFC.
// The header integer values should be 1 1 0 1 1 4 but in the RFC they are 3 3 0 3 3 8.
// The bug has been fixed here and reported here: https://www.rfc-editor.org/errata/eid6757
define constant $version-3-example-bytes
  = as(<byte-vector>,
       #[#x54, #x5a, #x69, #x66, #x33, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x54, #x5a, #x69, #x66,
         #x33, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x00,
         #x00, #x00, #x00, #x01, #x00, #x00, #x00, #x01, #x00, #x00, #x00, #x00, #x00, #x00, #x00, #x01,
         #x00, #x00, #x00, #x01, #x00, #x00, #x00, #x04, #x00, #x00, #x00, #x00, #x7f, #xe8, #x17, #x80,
         #x00, #x00, #x00, #x1c, #x20, #x00, #x00, #x49, #x53, #x54, #x00, #x01, #x01, #x0a, #x49, #x53,
         #x54, #x2d, #x32, #x49, #x44, #x54, #x2c, #x4d, #x33, #x2e, #x34, #x2e, #x34, #x2f, #x32, #x36,
         #x2c, #x4d, #x31, #x30, #x2e, #x35, #x2e, #x30, #x0a]);


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

define test test-load-tzif-version-1 ()
  let tzif = make(<tzif>,
                  name: "UTC",
                  data: $version-1-example-bytes,
                  source: "$version-1-example-bytes");
  let zone = load-zone(tzif);   // mutates tzif
  assert-equal(1, tzif.tzif-version);
  assert-equal(272, tzif.tzif-end-of-v1-data);
  assert-equal(-1, tzif.tzif-end-of-v2-data); // no v2+ data
  assert-equal(1, tzif.tzif-is-utc-count);
  assert-equal(1, tzif.tzif-is-std-count);
  assert-equal(27, tzif.tzif-leap-count);
  assert-equal(0, tzif.tzif-time-count);
  assert-equal(1, tzif.tzif-type-count);
  assert-equal(4, tzif.tzif-char-count);
  assert-equal(1, zone.subzones.size);
  assert-equal($minimum-time, zone.subzones[0].subzone-start-time);
end test;

define test test-load-tzif-version-2 ()
  let tzif = make(<tzif>,
                  name: "Pacific/Honolulu",
                  data: $version-2-example-bytes,
                  source: "$version-2-example-bytes");
  let zone = load-zone(tzif);
  assert-equal(2, tzif.tzif-version);
  assert-equal(147, tzif.tzif-end-of-v1-data);
  assert-equal(322, tzif.tzif-end-of-v2-data);
  assert-equal(6, tzif.tzif-is-utc-count);
  assert-equal(6, tzif.tzif-is-std-count);
  assert-equal(0, tzif.tzif-leap-count);
  assert-equal(7, tzif.tzif-time-count);
  assert-equal(6, tzif.tzif-type-count);
  assert-equal(20, tzif.tzif-char-count);
  assert-equal(8, zone.subzones.size);
  assert-equal($minimum-time, zone.subzones[7].subzone-start-time);
  // TODO: test some of the transition times
end test;

define test test-load-tzif-version-3 ()
  let tzif = make(<tzif>,
                  name: "Asia/Jerusalem",
                  data: $version-3-example-bytes,
                  source: "$version-3-example-bytes");
  let zone = load-zone(tzif);
  assert-equal(3, tzif.tzif-version);
  assert-equal(44, tzif.tzif-end-of-v1-data);
  assert-equal(109, tzif.tzif-end-of-v2-data);
  assert-equal(1, tzif.tzif-is-utc-count);
  assert-equal(1, tzif.tzif-is-std-count);
  assert-equal(0, tzif.tzif-leap-count);
  assert-equal(1, tzif.tzif-time-count);
  assert-equal(1, tzif.tzif-type-count);
  assert-equal(4, tzif.tzif-char-count);
  assert-equal(2, zone.subzones.size);
  assert-equal($minimum-time, zone.subzones[1].subzone-start-time);
  // TODO: test some of the transition times
end test;

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

  // {<subzone> EST o=-18000 dst=#f 2021-11-07T06:00:00.0Z...}
  // {<subzone> EDT o=-14400 dst=#t 2021-03-14T07:00:00.0Z...}

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
