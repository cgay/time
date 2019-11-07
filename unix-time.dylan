Module: %time

define c-function get-clock-monotonic-raw
  result clock-id :: <c-int>;
  c-name: "c_get_clock_monotonic_raw";
end;

define constant <c-time-t> = <c-long>;
define constant <c-clock-id-t> = <c-int>;

define c-struct <timespec>
  slot timespec-seconds :: <c-time-t>;
  slot timespec-nanoseconds :: <c-long>;
  pointer-type-name: <timespec*>;
end;

define c-function c-clock-gettime
  parameter clock-id :: <c-clock-id-t>;
  parameter timespec :: <timespec*>;
  result status :: <c-int>;
  c-name: "clock_gettime";
end;
