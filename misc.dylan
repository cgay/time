Module: %time

// Notice how I have deftly avoided having a catch-all utils.dylan file by instead calling it misc.dylan.

// I don't like the verbosity of false-or. Let's see how this looks.
define constant <string>? = false-or(<string>);
define constant <time>? = false-or(<time>);
