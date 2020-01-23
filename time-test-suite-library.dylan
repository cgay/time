Module: dylan-user

define library time-test-suite
  use common-dylan;
  use testworks;
  use time;
end;

define module time-test-suite
  use common-dylan;
  use testworks;
  use time;
  use %time;
end;
