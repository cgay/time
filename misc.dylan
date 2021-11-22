Module: %time

// Notice how I have deftly avoided having a catch-all utils.dylan file by
// instead calling it misc.dylan.


// --- Types ---

// I don't like the verbosity of false-or. Let's see how this looks.
define constant <string>? = false-or(<string>);
define constant <time>? = false-or(<time>);
define constant <zone>? = false-or(<zone>);


// --- Errors ---

// Errors explicitly signaled by this library are instances of <time-error>.
define class <time-error> (<simple-error>) end;

define function time-error(msg :: <string>, #rest format-args)
  error(make(<time-error>,
             format-string: msg,
             format-arguments: format-args));
end function;

// --- Debugging ---

define function debug-out (fmt, #rest args)
  apply(format-err, fmt, args);
  force-err();
end function;

// --- Macros ---

define macro iff
    { iff(?test:expression, ?true:expression, ?false:expression) }
 => { if (?test) ?true else ?false end }

    { iff(?test:expression, ?true:expression) }
 => { if (?test) ?true end }
end;


