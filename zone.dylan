Module: %time
Synopsis: Time zones implementation

// Returns the full name of the zone. Ex: "America/New York"
define sealed generic zone-name (zone :: <zone>) => (name :: <string>);

// Returns the local time zone, according to the operating system.
define generic local-time-zone () => (zone :: <zone>);

// The UTC offset in minutes at time `time` in zone `zone`. For `<aware-zone>`
// a time should be passed so the offset at that time may be determined. If
// not provided, the current time is used instead.
//
// It is possible, at least historically, to have an offset with fractional
// minutes but we don't support it.
define sealed generic zone-offset
    (zone :: <zone>, #key time) => (minutes :: <integer>);

// Returns a string describing the offset in minutes from UTC for zone `zone`
// at time `time`.  For example, "+00:00" or "Z" for UTC itself or "-04:00" for
// a time in EDT.
define sealed generic zone-offset-string
    (zone :: <zone>, #key time) => (offset :: <string>);

// Returns the short name of `zone`. The abbreviation is symbolic if possible
// (ex: "EDT", "UTC") and otherwise is the result of calling
// zone-offset-string. For `<aware-zone>` a time should be provided since the
// abbreviation may differ over time. If not provided, the current time is
// used.
define generic zone-abbreviation
    (zone :: <zone>, #key time) => (abbrev :: <string>);

// Returns true if the zone observes Daylight Savings Time at time `time`. For
// `<naive-zone>` this is always false. For `<aware-zone>` a time should be
// provided since the value may differ over time. If not provided, the current
// time is used.
define generic zone-daylight-savings?
    (zone :: <zone>, #key time) => (dst? :: <boolean>);


// A <subzone> represents the values for a timezone over a period of time
// starting at subzone-start-time and ending when a newer <subzone> shadows it.
define class <subzone> (<object>)
  // This can probably just be a number of minutes or seconds. TODO
  constant slot subzone-start-time :: <time>, required-init-keyword: start-time:;
  constant slot subzone-offset :: <integer>, required-init-keyword: offset:;
  constant slot subzone-abbrev :: <string>, required-init-keyword: abbrev:;
  constant slot subzone-dst? :: <boolean>, required-init-keyword: dst?:;
end class;

define abstract class <zone> (<object>)
  constant slot zone-name :: <string>, required-init-keyword: name:;
end class;

// Naive zones have a constant offset from UTC and constant abbreviation over time.
define class <naive-zone> (<zone>)
  constant slot %offset :: <integer>, required-init-keyword: offset:;
  constant slot %abbreviation :: <string>?, init-keyword: abbreviation:;
end class;

define method initialize (zone :: <naive-zone>, #key offset :: <integer>, #all-keys)
  // Validate the offset. Current max is +14h, min is -12h, but there's nothing
  // that says some place won't use a larger value, so arbitrarily choosing +/-
  // 15h, which will at least prevent crazy accidental values, for example if
  // seconds are used instead of minutes.
  if (offset > 15 * 60 | offset < -15 * 60)
    time-error("Time zone offsets must be between -15h (%d) and +15h (%d), got %=",
               -15 * 60, 15 * 60, offset);
  end;
end method;

// Aware zones may have different offsets or abbreviations over time.
define class <aware-zone> (<zone>)
  // The events describing how this zone differed from UTC over different time
  // periods, ordered newest first because the common case is assumed to be
  // asking about the current time.
  constant slot subzones :: <vector>, // of <subzone>
    required-init-keyword: subzones:;
end class;

define method initialize (zone :: <aware-zone>, #key subzones :: <vector>, #all-keys)
  let prev-time = #f;
  for (subzone in subzones)
    let offset = subzone.subzone-offset;
    if (offset > 15 * 60 | offset < -15 * 60)
      time-error("Time zone offsets must be between -15h (%d) and +15h (%d), got %=",
                 -15 * 60, 15 * 60, offset);
    end;
    let start = subzone.subzone-start-time;
    if (prev-time & prev-time <= start)
      time-error("Time zone data for %= is invalid; it should be older than %s",
                 subzone, prev-time);
    end;
    prev-time := start;
  end;
end method;

define constant $utc :: <naive-zone>
  = make(<naive-zone>,
         name: "Coordinated Universal Time",
         abbreviation: "UTC",
         offset: 0);

define method local-time-zone () => (zone :: <zone>)
  // TODO
  $utc
end method;

define function zone-subzone
    (zone :: <aware-zone>, time :: <time>) => (_ :: <subzone>)
  let subs = zone.subzones;
  let len :: <integer> = subs.size;
  iterate loop (i :: <integer> = 0)
    if (i < len)
      let subzone :: <subzone> = subs[i];
      if (time >= subzone.subzone-start-time)
        subzone
      else
        loop(i + 1)
      end
    else
      time-error("time zone %s has no data for time %=", time);
    end
  end iterate
end function;

define method zone-offset
    (zone :: <naive-zone>, #key time :: <time> = time-now())
 => (minutes :: <integer>)
  zone.%offset
end method;

define method zone-offset
    (zone :: <aware-zone>, #key time :: <time> = time-now())
 => (minutes :: <integer>)
  subzone-offset(zone-subzone(zone, time))
end method;

define method zone-abbreviation
    (zone :: <naive-zone>, #key time :: <time> = time-now())
 => (abbrev :: <string>)
  zone.%abbreviation | zone.zone-name
end method;

define method zone-abbreviation
    (zone :: <aware-zone>, #key time :: <time> = time-now())
 => (abbrev :: <string>)
  subzone-abbrev(zone-subzone(zone, time))
end method;

define method zone-daylight-savings?
    (zone :: <naive-zone>, #key time :: <time> = time-now())
 => (dst? :: <boolean>)
  #f
end method;

define method zone-daylight-savings?
    (zone :: <aware-zone>, #key time :: <time> = time-now())
 => (dst? :: <boolean>)
  subzone-dst?(zone-subzone(zone, time))
end method;

define /* inline */ function offset-to-string
    (offset :: <integer>) => (_ :: <string>)
  if (offset = 0)
    "+00:00"                    // frequent case? avoid allocation.
  else
    let (hours, minutes) = floor/(abs(offset), 60.0);
    concatenate(if (offset < 0) "-" else "+" end,
                integer-to-string(as(<integer>, hours), size: 2),
                ":",
                integer-to-string(as(<integer>, minutes), size: 2))
  end
end function;

// Returns the zone offset string in the form "+hh:mm" or "-hh:mm" where 'hh'
// and 'mm' are hours and minutes. The `time` parameter is ignored by this
// method.
define method zone-offset-string
    (zone :: <naive-zone>, #key time) => (offset :: <string>)
  offset-to-string(zone-offset(zone));
end method;

// Returns the zone offset string in the form "+hh:mm" or "-hh:mm" where 'hh'
// and 'mm' are hours and minutes. If `time` is supplied then the offset at
// that time is used, otherwise the offset at the current time is used.
define method zone-offset-string
    (zone :: <aware-zone>, #key time :: <time>?)
 => (offset :: <string>)
  offset-to-string(zone-offset(zone, time: time | time-now()))
end method;

