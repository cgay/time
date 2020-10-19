Module: dylan-user

define library time-test-suite
  use common-dylan;
  use testworks;
  use time;
  use io;
end;

define module time-test-suite
  use common-dylan;
  use testworks;
  use time;
  use %time;
  use format;
end;
