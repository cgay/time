Module: tzifdump

define function main
    (name :: <string>, arguments :: <vector>)
  let args = application-arguments();
  if (args.size ~== 1)
    format-err("Usage: %s tzif-file\n", application-name());
    force-err();
    exit-application(2);
  end;

  let file = as(<file-locator>, args[0]);
  let name = file.locator-name;
  let zone :: <zone> = load-tzif-file(name, file);
  dump-zone(zone);
  exit-application(0);
end function;

// Calling our top-level function (which may have any name) is the last
// thing we do.
main(application-name(), application-arguments());
