Module: time-test

define interface-specification-suite time-specification-suite ()
  // Time
  sealed instantiable class <time> (<object>);
  function time-now(#"key", #"zone") => (<time>);
  sealed generic function time-components
    (<time>) => (<integer>, <month>, <integer>, <integer>, <integer>, <integer>,
                 <integer>, <zone>, <day>);
  sealed generic function time-year         (<time>) => (<integer>);
  sealed generic function time-month        (<time>) => (<month>);
  sealed generic function time-day-of-month (<time>) => (<integer>);
  sealed generic function time-hour         (<time>) => (<integer>);
  sealed generic function time-minute       (<time>) => (<integer>);
  sealed generic function time-second       (<time>) => (<integer>);
  sealed generic function time-nanosecond   (<time>) => (<integer>);
  sealed generic function time-zone         (<time>) => (<zone>);
  sealed generic function time-day-of-week  (<time>) => (<day>);
  constant $epoch :: <time>;

  // Durations
  sealed instantiable class <duration> (<object>);
  sealed generic function duration-nanoseconds (<duration>) => (<integer>);
  constant $nanosecond :: <duration>;
  constant $microsecond :: <duration>;
  constant $millisecond :: <duration>;
  constant $second :: <duration>;
  constant $minute :: <duration>;
  constant $hour :: <duration>;

  // Days of the week
  sealed instantiable class <day> (<object>);
  sealed generic function day-full-name (<day>) => (<string>);
  sealed generic function day-short-name (<day>) => (<string>);
  constant $monday :: <day>;
  constant $tuesday :: <day>;
  constant $wednesday :: <day>;
  constant $thursday :: <day>;
  constant $friday :: <day>;
  constant $saturday :: <day>;
  constant $sunday :: <day>;

  // Months
  sealed instantiable class <month> (<object>);
  sealed generic function month-number (<month>) => (<integer>);
  sealed generic function month-full-name (<month>) => (<string>);
  sealed generic function month-short-name (<month>) => (<string>);
  sealed generic function month-days (<month>) => (<integer>);
  constant $january :: <month>;
  constant $february :: <month>;
  constant $march :: <month>;
  constant $april :: <month>;
  constant $may :: <month>;
  constant $june :: <month>;
  constant $july :: <month>;
  constant $august :: <month>;
  constant $september :: <month>;
  constant $october :: <month>;
  constant $november :: <month>;
  constant $december :: <month>;

  // Conversions
  sealed generic function time-in-zone (<time>, <zone>) => (<time>);
  sealed generic function time-in-utc (<time>) => (<time>);
  sealed generic function make-time
      (<integer>, <integer>, <integer>, <integer>, <integer>, <integer>, #"key", #"zone")
   => (<time>);
  sealed generic function parse-time (<string>, <object>, #"key", #"zone") => (<time>);
  sealed generic function parse-duration (<string>) => (<duration>);
  sealed generic function parse-day (<string>) => (<day>);

  // TODO: Really not sure yet the best API for outputting time and duration values.

  // print-time calls format-time but provides defaults.
  function print-time (<time>, #"key", #"stream", #"format") => ();
  // format-time matches the argument order of format.
  open generic function format-time (<stream>, <time-format>, <time>) => ();

  function print-duration (<duration>, #"key", #"style") => ();
  open generic function format-duration (<stream>, <duration-style>, <duration>) => ();

  // Comparisons
  // TODO(https://github.com/dylan-lang/testworks/issues/97):
  // generic-funtion-method \< (<duration>, <duration>) => (<boolean>);
  // generic-funtion-method \= (<duration>, <duration>) => (<boolean>);
  // generic-funtion-method \< (<time>, <time>) => (<boolean>);
  // generic-funtion-method \= (<time>, <time>) => (<boolean>);

  // Arithmetic
  // TODO(https://github.com/dylan-lang/testworks/issues/97):
  // generic-funtion-method \+ (<duration>, <duration>) => (<duration>);
  // generic-funtion-method \+ (<time>, <duration>) => (<time>);
  // generic-funtion-method \+ (<duration>, <time>) => (<time>);
  // generic-funtion-method \- (<duration>, <duration>) => (<duration>);
  // generic-funtion-method \- (<time>, <duration>) => (<time>);
  // generic-funtion-method \* (<real>, <duration>) => (<duration>);
  // generic-funtion-method \* (<duration>, <real>) => (<duration>);
  // generic-funtion-method \/ (<duration>, <real>) => (<duration>);

  // Zones
  sealed abstract class <zone> (<object>);
  sealed generic function local-time-zone () => (<zone>);
  sealed generic function zone-short-name (<zone>) => (<string>);
  sealed generic function zone-full-name (<zone>) => (<string>);
  sealed generic function zone-offset (<zone>) => (<integer>);
  sealed generic function zone-offset-string (<zone>) => (<string>);
  constant $utc :: <zone>;
end interface-specification-suite;

ignore(time-specification-suite);

define sideways method make-test-instance (class == <day>) => (day :: <day>)
  make(<day>, full-name: "Today", short-name: "2day")
end;

define sideways method make-test-instance (class == <month>) => (month :: <month>)
  make(<month>, full-name: "Month", short-name: "Mes", number: 12, days: 31)
end;
