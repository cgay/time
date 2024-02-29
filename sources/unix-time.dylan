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

// Note that Unix time does not include leap seconds and that will matter when we convert
// to y/d/m/h/m/s.
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


// --- Find local time zone from system configuration ---

// Much of this is cribbed from Python's tzlocal package.

define function %local-time-zone
    (#key root-directory = "/") => (zone :: <zone>)
  find-zone-from-environment(root-directory)
    | find-zone-from-etc-timezone(root-directory)
    | find-zone-from-etc-sysconfig-clock(root-directory)
    | find-zone-from-systemd-link(root-directory)
    | find-zone-from-etc-localtime(root-directory)
    | $utc
end function;

// https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html
// specifies a bunch of $TZ formats that we won't support because Python
// doesn't either. I'm assuming they're obsolete.
define function find-zone-from-environment
    (root-directory :: <string>) => (zone :: <zone>?)
  // TODO
end function;

define function find-zone-from-etc-timezone
    (root-directory :: <string>) => (zone :: <zone>?)
  // TODO
end function;

define function find-zone-from-etc-sysconfig-clock
    (root-directory :: <string>) => (zone :: <zone>?)
  // TODO
end function;

// systemd distributions use symlinks that include the zone name.
// Ex: /etc/localtime -> /usr/share/zoneinfo/UTC
define function find-zone-from-systemd-link
    (root-directory :: <string>) => (zone :: <zone>?)
  let filename = concatenate(root-directory, "etc/localtime");
  if (file-exists?(filename))
    let real-path = resolve-locator(as(<file-locator>, filename));
    let tzname = locator-base(real-path);
    find-zone(tzname)
  end
end function;

define function find-zone-from-etc-localtime
    (root-directory :: <string>) => (zone :: <zone>?)
  // TODO
end function;


// --- Loading zones ---

// This is the per-platform entry point to load zone data from the file system.
define function load-all-zones
    () => (zones :: <string-table>)
  // TODO: This should use the TZDIR environment variable once leap seconds are
  // supported.  Usually that should point to /usr/share/zoneinfo/posix (based on UTC
  // without leap seconds) or /usr/share/zoneinfo/right (based on International Atomic
  // Time (TAI) and accounting for leap seconds).
  let path = select (os/$os-name)
               #"linux" => "/usr/share/zoneinfo/posix";
               #"darwin" => "/usr/share/zoneinfo.default";
               otherwise =>
                 time-error("The time library does not yet support the %= operating system.",
                            os/$os-name)
             end;
  load-tzif-zones(as(<directory-locator>, path))
end function;
