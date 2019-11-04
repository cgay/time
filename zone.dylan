Module: %time

// Returns the name of zone `z`. In some cases the name may be an offset string
// as returned by `zone-offset-string`.
define generic zone-name (z :: <time-zone>) => (name :: <string>);

// Returns the number of minutes offset from UTC for zone `z` at time `t`.
define generic zone-offset (z :: <time-zone>, t :: <time>) => (minutes :: <integer>);

// Returns a string describing the offset from UTC for zone `z` at time `t`.
// For example, "+0000" for UTC itself or "-0400" for EDT. Use `zone-name` if
// you want to display the mnemonic zone name instead. If this zone didn't
// exist at time `t` a `<time-error>` is signaled.
define generic zone-offset-string (z :: <time-zone>, t :: <time>) => (offset :: <string>);

// Time zone. A "naive" time zone is one that has always been and will always
// be at the same offset from UTC. This is represented by having a single
// element in the `%offsets` sequence. See `$utc` for an example.
define class <time-zone> (<object>)
  // The name or abbreviation for the zone, like "UTC" or "CET". For naive time
  // zones this could be, for example, "UTC-0500".
  constant slot zone-name :: <string>, required-init-keyword: name:;

  // The historical offsets from UTC, ordered newest first because the common
  // case is assumed to be asking about the current time. Each element is a
  // pair(start-time, integer-offset) indicating that at start-time the offset
  // was integer-offset minutes from UTC.  If this zone didn't exist at time
  // `t` a `<time-error>` is signaled.
  //
  // TODO: no idea how often zones change. Need to look at the tz data. It's
  // possible that it's worth using a balanced tree of some sort for this.
  constant slot %offsets :: <sequence>, init-keyword: offsets:;
end class;

define method zone-offset (z :: <time-zone>, t :: <time>) => (minutes :: <integer>)
  let offsets = z.%offsets;
  let len :: <integer> = offsets.size;
  iterate loop (i :: <integer> = 0)
    if (i < len)
      let offset = offsets[i];
      let start-time = offset.head;
      if (start-time < t)
        offset.tail
      else
        loop(i + 1)
      end
    else
      time-error("time zone %s has no offset data for time %=", t);
    end
  end iterate
end method;

define method zone-offset-string (z :: <time-zone>, t :: <time>) => (offset :: <string>)
  let offset = zone-offset(z, t);
  let (hours, minutes) = floor/(abs(offset), 60);
  let sign = if (offset < 0) "-" else "+" end;
  format-to-string("%s%02d%02d", sign, hours, round(minutes))
end method;
