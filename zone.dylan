Module: %time
Synopsis: Time zones implementation

define abstract class <zone> (<object>)
  constant slot %name :: <string>, init-keyword: name:;
  constant slot %abbrev :: <string>, init-keyword: abbreviation:;
end class;

define class <naive-zone> (<zone>)
  constant slot %offset :: <integer>, required-init-keyword: offset:;
end class;

define method make
    (class == <naive-zone>, #key offset :: <integer>, abbreviation, name, #all-keys)
 => (zone :: <zone>)
  let abbrev = abbreviation | offset-to-utc-abbrev(offset);
  make(<naive-zone>,
       offset: offset,
       abbreviation: abbrev,
       name: name | abbrev)
end method;

// TODO: this should subclass <zone> but I'm making it subclass <naive-zone>
// until tzdata is implemented.
define class <aware-zone> (<naive-zone>)

  // The historical offsets from UTC, ordered newest first because the common
  // case is assumed to be asking about the current time. Each element is a
  // pair(start-time, integer-offset) indicating that at start-time the offset
  // was integer-offset minutes from UTC.  If this zone didn't exist at time
  // `t` a `<time-error>` is signaled.
  //
  // TODO: no idea how often zones change. Need to look at the tz data. It's
  // possible that it's worth using a balanced tree of some sort for this.
  constant slot %offsets :: <sequence>,
    required-init-keyword: offsets:;
end class;

// TODO: a make method with some error checking of the offsets

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

define method %zone-abbreviation
    (time :: <time>, zone :: <aware-zone>) => (name :: <string>)
  // TODO
  next-method()
end method;

define method zone-long-name (z :: <zone>) => (name :: <string>)
  // z.%long-name | zone-offset-string(z, time: time-now());
  "TODO"
end method;

define method local-time-zone () => (zone :: <zone>)
  // TODO
  $utc
end method;

// TODO: return seconds? rare, but happens per RFC 3339
define method zone-offset
    (zone :: <naive-zone>, #key time :: false-or(<time>))
 => (minutes :: <integer>)
  zone.%offset
end method;

define method zone-offset
    (zone :: <aware-zone>, #key time :: false-or(<time>)) => (minutes :: <integer>)
  let time = time | time-now();
  let offsets = zone.%offsets;
  let len :: <integer> = offsets.size;
  iterate loop (i :: <integer> = 0)
    if (i < len)
      let offset = offsets[i];
      let start-time = offset.head;
      if (start-time < time)
        offset.tail
      else
        loop(i + 1)
      end
    else
      time-error("time zone %s has no offset data for time %=", time);
    end
  end iterate
end method;

define method zone-offset-string
    (z :: <zone>, #key time :: false-or(<time>)) => (offset :: <string>)
  let offset = zone-offset(z, time: time);
  let (hours, minutes) = floor/(abs(offset), 60);
  let sign = if (offset < 0) "-" else "+" end;
  format-to-string("%s%02d%02d", sign, hours, round(minutes))
end method;
