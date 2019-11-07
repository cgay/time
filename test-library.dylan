Module: dylan-user

define library time-test
  use common-dylan;
  use testworks;
  use time;
end;

define module time-test
  use common-dylan;
  use testworks;
  use time;
  use %time;
end;
