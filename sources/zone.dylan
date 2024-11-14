Module: %time
Synopsis: Time zones implementation

// Returns the full name of the zone. Ex: "America/New_York"
// See also: `zone-abbreviation`.
define sealed generic zone-name (zone :: <zone>) => (name :: <string>);

// Returns the local time zone, according to the operating system.
define generic local-time-zone () => (zone :: <zone>);

// The UTC offset in seconds at time `time` in zone `zone`. For `<aware-zone>`
// a time should be passed so the offset at that time may be determined. If
// not provided, the current time is used instead.
define sealed generic zone-offset-seconds
    (zone :: <zone>, #key time) => (seconds :: <integer>);

// Returns a string describing the offset in minutes from UTC for zone `zone`
// at time `time`.  For example, "+00:00" or "Z" for UTC itself or "-04:00" for
// a time in EDT.
// TODO: what about seconds? Only include them when non-zero?
define sealed generic zone-offset-string
    (zone :: <zone>, #key time) => (offset :: <string>);

// Returns the short name of `zone`.  The abbreviation is symbolic if possible (Ex:
// "EDT", "UTC") and otherwise is the result of calling zone-offset-string.  For
// `<aware-zone>` a time should be provided since the abbreviation may differ over time.
// If not provided, the current time is used.
define generic zone-abbreviation
    (zone :: <zone>, #key time) => (abbrev :: <string>);

// Returns true if the zone observes Daylight Savings Time at time `time`. For
// `<naive-zone>` this is always false. For `<aware-zone>` a time should be
// provided since the value may differ over time. If not provided, the current
// time is used.
define generic zone-daylight-savings?
    (zone :: <zone>, #key time) => (dst? :: <boolean>);


// RFC 9636 (TZif) min and max TZ offset values, in seconds.
define constant $min-offset-seconds = -25 * 60 * 60 + 1; // -89999
define constant $max-offset-seconds =  26 * 60 * 60 - 1; //  93599

define inline function check-offset (offset :: <integer>)
  if (offset < $min-offset-seconds | offset > $max-offset-seconds)
    time-error("Time zone offsets must be seconds in the range [%d, %d], got %=",
               $min-offset-seconds, $max-offset-seconds, offset);
  end;
end function;

// A <transition> represents a change in the attributes of a zone that begins at a
// particular UTC time and ends when a later <transition> (if any) shadows it.
define class <transition> (<object>)
  // Time this transition takes effect, as a number of seconds since the POSIX epoch,
  // including leap seconds. (Since I believe that to be equivalent to UTC time, that's
  // what I've named it. -cgay) The minumum conforming value is -2^59 or
  // -#x800_0000_0000_0000, which can cause overflows when converted to microseconds, so
  // the minimum value we store here is floor/($minimum-time.%microseconds, 1_000_000).
  constant slot %utc-seconds :: <integer>,
    required-init-keyword: utc-seconds:;
  constant slot %offset-seconds :: <integer>,
    required-init-keyword: offset-seconds:;
  // RFC 9636, section 4: Time zone designations MUST consist of at least three (3) and
  // no more than six (6) ASCII characters from the set of alphanumerics, "-", and "+".
  constant slot %abbreviation :: <string>,
    required-init-keyword: abbreviation:;
  constant slot %dst? :: <boolean>,
    required-init-keyword: dst?:;
end class;

define method initialize (transition :: <transition>, #key offset-seconds :: <integer>)
  check-offset(offset-seconds);
end method;

define method print-object (transition :: <transition>, stream :: <stream>) => ()
  let offset = transition.%offset-seconds;
  local
    method safe-time (seconds, offset)
      // It is possible for overflow to occur when applying the offset. Let's not die
      // horribly.
      block ()
        make(<time>, microseconds: seconds * 1_000_000 + offset * 1_000_000)
      exception (<arithmetic-overflow-error>)
        format-to-string("%d seconds UTC", seconds + offset)
      end
    end method,
    method doit ()
      // This output is designed to be useful for our tzifdump utility.
      format(stream, "%s = %s %-4s %6s dst: %s",
             with-output-to-string (s)
               let t = safe-time(transition.%utc-seconds, 0);
               format-time(s, "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}Z", t);
             end,
             with-output-to-string (s)
               let t = safe-time(transition.%utc-seconds, offset);
               let z = make(<naive-zone>, offset: offset);
               format-time(s, "{yyyy}-{mm}-{dd}T{HH}:{MM}:{SS}{offset}", t, zone: z);
             end,
             transition.%abbreviation,
             with-output-to-string (s)
               %format-zone-offset(s, offset, #f, #f);
             end,
             iff(transition.%dst?, "yes", "no"));
    end method;
  iff(*print-escape?*,
      printing-object(transition, stream) doit() end,
      doit());
end method;

define abstract class <zone> (<object>)
  constant slot zone-name :: <string>, required-init-keyword: name:;
end class;

// Naive zones have a constant offset from UTC and constant abbreviation over
// time.
define class <naive-zone> (<zone>)
  constant slot %offset-seconds :: <integer>, required-init-keyword: offset-seconds:;
  constant slot %abbreviation :: <string?>, init-keyword: abbreviation:;
end class;

define method initialize (zone :: <naive-zone>, #key offset-seconds :: <integer>)
  check-offset(offset-seconds);
end method;

define method print-object (zone :: <naive-zone>, stream :: <stream>) => ()
  printing-object(zone, stream)
    format(stream, "%= (%s) %s",
           zone.zone-name, zone.%abbreviation, zone-offset-string(zone));
  end;
end method;

// Aware zones may have different offsets or abbreviations over time.
define class <aware-zone> (<zone>)
  // The events describing how this zone differed from UTC over different time
  // periods, ordered newest first because the common case is assumed to be
  // asking about recent times.
  constant slot %transitions :: <vector>, // of <transition>
    required-init-keyword: transitions:;
end class;

define method initialize (zone :: <aware-zone>, #key transitions :: <vector>, #all-keys)
  let prev-start-time = #f;
  for (transition in transitions)
    let start-time = transition.%utc-seconds;
    if (prev-start-time & prev-start-time <= start-time)
      time-error("Transition start time (%s) for %s is invalid; it must be older than"
                   " the transition that preceded it, %s.",
                 start-time, transition, prev-start-time);
    end;
    prev-start-time := start-time;
  end;
end method;

define method print-object (zone :: <aware-zone>, stream :: <stream>) => ()
  if (*print-escape?*)
    printing-object(zone, stream)
      format(stream, "%s, %d transitions", zone.zone-name, zone.%transitions.size);
    end;
  else
    format(stream, "%s, %d transitions", zone.zone-name, zone.%transitions.size);
  end;
end method;

define method dump-zone (zone :: <aware-zone>) => ()
  format-out("%s\n", zone);
  for (sub in zone.%transitions using backward-iteration-protocol,
       first? = #t then #f)
    // Skip first zone, which is there for internal reasons. See decode-tzif-data-block.
    if (~first?)
      format-out("%s\n", sub);
    end;
  end;
end method;

define constant $utc :: <naive-zone>
  = make(<naive-zone>,
         name: "Coordinated Universal Time",
         abbreviation: "UTC",
         offset-seconds: 0);

define variable *local-time-zone* :: <zone?> = #f;

define constant $local-time-zone-lock = make(<lock>);

define method local-time-zone () => (zone :: <zone>)
  *local-time-zone*
    | with-lock ($local-time-zone-lock)
        *local-time-zone*       // check again with lock held
          | (*local-time-zone* := %local-time-zone()); // platform specific implementations
      end
end method;

// Find the transition in `zone` that corresponds to the transition time `seconds`, which is
// seconds since the POSIX epoch.  If `seconds` is false then current time is assumed and
// the latest transition is returned. Signals `<time-error>` if no transition can be found.
define function zone-transition
    (zone :: <aware-zone>, seconds :: <integer?>) => (z :: <transition>)
  let subs = zone.%transitions;     // In order, newest transition first.
  if (~seconds)
    subs[0]
  else
    let len :: <integer> = subs.size;
    iterate loop (i :: <integer> = 0)
      if (i < len)
        let transition :: <transition> = subs[i];
        if (seconds >= transition.%utc-seconds)
          transition
        else
          loop(i + 1)
        end
      else
        // We effectively extend the oldest transition infinitely into the past.
        // This is consistent with this text from the tzfile man page:
        //   "Also, if there is at least one transition, time type 0 is associated with the
        //   time period from the indefinite past up to but not including the earliest
        //   transition time."
        // We assume `initialize(<aware-zone>)` requires at least one zone, which may change
        // once I implement the version 2+ TZif footer record.
        subs[subs.size - 1]
      end if
    end iterate
  end if
end function;

define method zone-offset-seconds
    (zone :: <naive-zone>, #key time :: <time?>) => (seconds :: <integer>)
  ignore(time);
  zone.%offset-seconds
end method;

define method zone-offset-seconds
    (zone :: <aware-zone>, #key time :: <time?>)
 => (seconds :: <integer>)
  %zone-offset-seconds(zone, time & time.%microseconds)
end method;

define method %zone-offset-seconds
    (zone :: <naive-zone>, micros :: <integer?>) => (seconds :: <integer>)
  ignore(micros);
  zone.%offset-seconds
end method;

define method %zone-offset-seconds
    (zone :: <aware-zone>, micros :: <integer?>) => (seconds :: <integer>)
  %offset-seconds(zone-transition(zone, micros))
end method;

define method zone-abbreviation
    (zone :: <naive-zone>, #key time :: <time?>)
 => (abbrev :: <string>)
  zone.%abbreviation | zone.zone-name
end method;

define method zone-abbreviation
    (zone :: <aware-zone>, #key time :: <time?>)
 => (abbrev :: <string>)
  %abbreviation(zone-transition(zone, time & time.%microseconds))
end method;

define method zone-daylight-savings?
    (zone :: <naive-zone>, #key time :: <time?>)
 => (dst? :: <boolean>)
  #f
end method;

define method zone-daylight-savings?
    (zone :: <aware-zone>, #key time :: <time?>)
 => (dst? :: <boolean>)
  %dst?(zone-transition(zone, time & time.%microseconds))
end method;

define function offset-to-string
    (offset :: <integer>) => (_ :: <string>)
  if (offset == 0)
    "+00:00"                    // frequent case? avoid allocation.
  else
    let (hours, minutes) = floor/(abs(offset), 60);
    concatenate(if (offset < 0) "-" else "+" end,
                integer-to-string(hours, size: 2),
                ":",
                integer-to-string(minutes, size: 2))
  end
end function;

// Returns the zone offset string in the form "+hh:mm" or "-hh:mm" where 'hh'
// and 'mm' are hours and minutes. The `time` parameter is ignored by this
// method.
define method zone-offset-string
    (zone :: <naive-zone>, #key time) => (offset :: <string>)
  offset-to-string(zone-offset-seconds(zone));
end method;

// Returns the zone offset string in the form "+hh:mm" or "-hh:mm" where 'hh'
// and 'mm' are hours and minutes. If `time` is supplied then the offset at
// that time is used, otherwise the offset at the current time is used.
define method zone-offset-string
    (zone :: <aware-zone>, #key time :: <time?>) => (offset :: <string>)
  offset-to-string(zone-offset-seconds(zone, time: time | time-now()))
end method;


// --- Zone database ---

// Maps zone names to <zone>s. Note that multiple names may map to the same zone.
define variable *zones* :: <string-table> = make(<string-table>);

// Find a time zone by name. The `zones` parameter is intended for use by tests.
define function find-zone (name :: <string>, #key zones) => (zone :: <zone?>)
  element(zones | *zones*, name, default: #f)
end function;

// To be called at library initialization time.
define function initialize-zones () => ()
  *zones* := load-all-zones();
end function;
