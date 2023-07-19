Module: dylan-user

define library time-test-suite
  use big-integers;
  use common-dylan;
  use generic-arithmetic;
  use io;
  use regular-expressions;
  use system;
  use testworks;
  use time;
end;

define module time-test-suite
  use common-dylan;
  use file-system;
  use format;
  use generic-arithmetic,
    prefix: "ga/";
  use locators;
  use regular-expressions;
  use streams;
  use testworks;
  use time;
  use %time;
end;
