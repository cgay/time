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
  constant slot timespec-seconds :: <c-time-t>;
  constant slot timespec-nanoseconds :: <c-long>;
  pointer-type-name: <timespec*>;
end;

define c-function clock-gettime
  parameter clock-id :: <c-clock-id-t>;
  parameter timespec :: <timespec*>;
  result status :: <c-int>;
  c-name: "clock_gettime";
end;

define c-struct <tm>
  constant slot tm-sec :: <c-int>;
  constant slot tm-min :: <c-int>;
  constant slot tm-hour :: <c-int>;
  constant slot tm-mday :: <c-int>;
  constant slot tm-mon :: <c-int>;
  constant slot tm-year :: <c-int>;
  constant slot tm-wday :: <c-int>;
  constant slot tm-yday :: <c-int>;
  constant slot tm-isdst :: <c-int>;
  pointer-type-name: <tm*>;
end;

define c-function c-gmtime
  parameter time :: <c-time-t*>;
  result tm :: <tm*>;
  c-name: "gmtime_r";
end;

// for now
ignore(get-clock-monotonic-raw,
       tm-mday, tm-min, tm-isdst, tm-mon, tm-year,
       tm-wday, tm-yday, tm-sec, tm-hour,
       c-gmtime);
