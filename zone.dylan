Module: %time
Synopsis: Time zones implementation

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
  // The historical offsets from UTC, ordered newest first because the common
  // case is assumed to be asking about the current time. Each element is a
  // pair(start-time, offset-minutes) indicating that at start-time the offset
  // was integer-offset minutes from UTC. (Might want to consider better storage
  // formats at some point.)
  // TODO: store <tz-event>s instead
  constant slot %offsets :: <vector>, required-init-keyword: offsets:;
end class;

define method initialize (zone :: <aware-zone>, #key offsets :: <sequence>, #all-keys)
  // Validate the offsets, similar to <naive-zone>.
  let prev-time = #f;
  for (event in offsets)
    let offset = event.tail;
    if (offset > 15 * 60 | offset < -15 * 60)
      time-error("Time zone offsets must be between -15h (%d) and +15h (%d), got %=",
                 -15 * 60, 15 * 60, offset);
    end;
    if (prev-time & prev-time <= event.head)
      time-error("Time zone data for %= is invalid; it should be older than %s",
                 event, prev-time);
    end;
    prev-time := event.head;
  end;
end method;

// Returns a string such as "UTC", "UTC-5", or "UTC+3:30".
define function offset-to-utc-abbrev (offset :: <integer>) => (abbrev :: <string>)
  let (hours, minutes) = floor/(abs(offset), 60);
  let sign = if (offset < 0) "-" else "+" end;
  if (minutes = 0)
    if (hours = 0)
      "UTC"
    else
      concatenate("UTC", sign, integer-to-string(hours))
    end
  else
    format-to-string("UTC%s%d%02d", sign, hours, minutes)
  end
end function;

define method zone-abbreviation
    (zone :: <naive-zone>, #key time) => (name :: <string>)
  zone.%abbreviation | zone.zone-name
end method;

define method zone-abbreviation
    (zone :: <aware-zone>, #key time :: <time>?)
 => (name :: <string>)
  // TODO
  zone.zone-name
end method;

define method local-time-zone () => (zone :: <zone>)
  // TODO
  $utc
end method;

define method zone-offset
    (zone :: <naive-zone>, #key time) => (minutes :: <integer>)
  zone.%offset
end method;

define method zone-offset
    (zone :: <aware-zone>, #key time :: <time>?)
 => (minutes :: <integer>)
  let time = time | time-now();
  let offsets = zone.%offsets;
  let len :: <integer> = offsets.size;
  iterate loop (i :: <integer> = 0)
    if (i < len)
      let offset = offsets[i];
      let start-time = offset.head;
      if (time >= start-time)
        offset.tail
      else
        loop(i + 1)
      end
    else
      time-error("time zone %s has no data for time %=", time);
    end
  end iterate
end method;

define inline function offset-to-string
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
