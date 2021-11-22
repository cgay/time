Module: %time
Synopsis: Time zones implementation

// Returns the full name of the zone. Ex: "America/New York"
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


// RFC 8536 (TZif) min and max tz offset values, in seconds.
define constant $min-offset-seconds = -25 * 60 * 60 + 1;
define constant $max-offset-seconds =  26 * 60 * 60 - 1;

define inline function check-offset (offset :: <integer>)
  if (offset < $min-offset-seconds | offset > $max-offset-seconds)
    time-error("Time zone offsets must be seconds in the range (%d, %d), got %=",
               $min-offset-seconds, $max-offset-seconds, offset);
  end;
end function;

// A <subzone> represents the values for a timezone over a period of time
// starting at subzone-start-time and ending when a newer <subzone> shadows it.
define class <subzone> (<object>)
  // This can probably just be a number of minutes or seconds. TODO
  constant slot subzone-start-time :: <time>, required-init-keyword: start-time:;
  constant slot subzone-offset-seconds :: <integer>, required-init-keyword: offset-seconds:;
  constant slot subzone-abbrev :: <string>, required-init-keyword: abbrev:;
  constant slot subzone-dst? :: <boolean>, required-init-keyword: dst?:;
end class;

define method initialize (subzone :: <subzone>, #key offset-seconds :: <integer>)
  check-offset(offset-seconds);
end method;

define method print-object (s :: <subzone>, stream :: <stream>) => ()
  printing-object(s, stream)
    format(stream, "%s o=%d dst=%= %s...",
           s.subzone-abbrev, s.subzone-offset-seconds, s.subzone-dst?,
           s.subzone-start-time);
  end;
end method;

define abstract class <zone> (<object>)
  constant slot zone-name :: <string>, required-init-keyword: name:;
end class;

// Naive zones have a constant offset from UTC and constant abbreviation over
// time.
define class <naive-zone> (<zone>)
  constant slot %offset-seconds :: <integer>, required-init-keyword: offset-seconds:;
  constant slot %abbreviation :: <string>?, init-keyword: abbreviation:;
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
  // asking about the current time.
  constant slot subzones :: <vector>, // of <subzone>
    required-init-keyword: subzones:;
end class;

define method initialize (zone :: <aware-zone>, #key subzones :: <vector>, #all-keys)
  let time1 = #f;
  for (subzone in subzones)
    let start = subzone.subzone-start-time;
    if (time1 & time1 <= start)
      time-error("Subzone start time (%s) for %s is invalid; it should be older than"
                   " the subzone that preceded it, %s.", start, subzone, time1);
    end;
    time1 := start;
  end;
end method;

define method print-object (zone :: <aware-zone>, stream :: <stream>) => ()
  printing-object(zone, stream)
    format(stream, "%s, %d subzones", zone.zone-name, zone.subzones.size);
  end;
end method;

define constant $utc :: <naive-zone>
  = make(<naive-zone>,
         name: "Coordinated Universal Time",
         abbreviation: "UTC",
         offset-seconds: 0);

define variable *local-time-zone* :: <zone>? = #f;

define constant $local-time-zone-lock = make(<lock>);

define method local-time-zone () => (zone :: <zone>)
  *local-time-zone*
    | with-lock ($local-time-zone-lock)
        *local-time-zone*       // check again with lock held
          | (*local-time-zone* := %local-time-zone()); // platform specific implementations
      end
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

define method zone-offset-seconds
    (zone :: <naive-zone>, #key time) => (minutes :: <integer>)
  zone.%offset-seconds
end method;

define method zone-offset-seconds
    (zone :: <aware-zone>, #key time :: <time> = time-now())
 => (minutes :: <integer>)
  subzone-offset-seconds(zone-subzone(zone, time))
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
  offset-to-string(zone-offset-seconds(zone));
end method;

// Returns the zone offset string in the form "+hh:mm" or "-hh:mm" where 'hh'
// and 'mm' are hours and minutes. If `time` is supplied then the offset at
// that time is used, otherwise the offset at the current time is used.
define method zone-offset-string
    (zone :: <aware-zone>, #key time :: <time>?) => (offset :: <string>)
  offset-to-string(zone-offset-seconds(zone, time: time | time-now()))
end method;

define constant $zones-by-long-name :: <string-table> = make(<string-table>);
define constant $zones-by-abbreviation :: <string-table> = make(<string-table>);

// Find a zone by long name and then, if not found, fall back to abbreviations.
define function find-zone (name :: <string>) => (zone :: <zone>?)
  element($zones-by-long-name, name, default: #f)
    | element($zones-by-abbreviation, name, default: #f)
end function;
