Module: dylan-user

define library time-test-suite
  use common-dylan;
  use testworks;
  use time;
  use io;
end;

define module time-test-suite
  use common-dylan;
  use format;
  use streams,
    import: { with-output-to-string };
  use testworks;
  use time;
  use %time;
end;
