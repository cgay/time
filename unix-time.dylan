Module: %time

define c-function get-clock-realtime
  result clock-id :: <c-int>;
  c-name: "c_get_clock_realtime";
end;

define c-function get-clock-monotonic-raw
  result clock-id :: <c-int>;
  c-name: "c_get_clock_monotonic_raw";
end;

define constant <c-time-t> = <c-long>;
define constant <c-time-t*> = <c-long*>;
define constant <c-clock-id-t> = <c-int>;

define c-struct <timespec>
  slot timespec-seconds :: <c-time-t>;
  slot timespec-nanoseconds :: <c-long>;
  pointer-type-name: <timespec*>;
end;

define c-function clock-gettime
  parameter clock-id :: <c-clock-id-t>;
  parameter timespec :: <timespec*>;
  result status :: <c-int>;
  c-name: "clock_gettime";
end;

define c-struct <tm>
  slot tm-sec :: <c-int>;
  slot tm-min :: <c-int>;
  slot tm-hour :: <c-int>;
  slot tm-mday :: <c-int>;
  slot tm-mon :: <c-int>;
  slot tm-year :: <c-int>;
  slot tm-wday :: <c-int>;
  slot tm-yday :: <c-int>;
  slot tm-isdst :: <c-int>;
  pointer-type-name: <tm*>;
end;

define c-function c-gmtime
  parameter time :: <c-time-t*>;
  result tm :: <tm*>;
  c-name: "gmtime_r";
end;
