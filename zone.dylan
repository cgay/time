Module: %time

// TODO: perhaps this should return a <duration>?
define generic zone-offset (z :: <zone>, t :: <time>) => (minutes :: <integer>);
define generic zone-offset-string (z :: <zone>, t :: <time>) => (offset :: <string>);
define generic zone-name (z :: <zone>) => (name :: <string>);


define abstract sealed class <zone> (<object>)
  // The name or abbreviation for the zone, like "UTC".  For simple
  // zones (i.e., just a single offset that never changes) this may be
  // the string rep of the offset, such as "-0500".  This may be the
  // empty string, in which case only the offset is used for
  // presentation.
  slot zone-name :: <string>, required-init-keyword: name:;
end;

// TODO: maybe the subclasses aren't necessary and "awareness" can be
// determined by whether or not history data is available.

// A zone that doesn't know about changes in offset over time.
define class <simple-zone> (<zone>)
  slot %offset :: <integer>, required-init-keyword: offset:;
end;

define constant $utc :: <simple-zone> = make(<simple-zone>, name: "UTC", offset: 0);

// A zone that knows about changes in offset over time.
define class <aware-zone> (<zone>)
  // TODO: slot %offsets :: <collection>, ...
end;

