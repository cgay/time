Module: dylan-user
Synopsis: Dump TZif files like those in /usr/share/zoneinfo

define library tzifdump
  use common-dylan;
  use io, import: { format-out };
  use system, import: { locators };
  use time;
end library;

define module tzifdump
  use common-dylan;
  use format-out;
  use locators;
  use time;
end module;
