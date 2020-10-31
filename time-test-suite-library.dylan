Module: dylan-user

define library time-test-suite
  use common-dylan;
  use io;
  use system;
  use testworks;
  use time;
end;

define module time-test-suite
  use common-dylan;
  use format;
  use locators;
  use streams;
  use testworks;
  use time;
  use %time;
end;
