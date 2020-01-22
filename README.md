# A Time Library for Dylan

This library is intended to be an improvement on the Open Dylan `date` library
for several reasons:

*  More complete -- it will have full time zone support.
*  More efficient -- each `<time>` instance uses far less memory.
*  More precision -- nanoseconds rather than microseconds.
*  Better naming -- What can I say? I just never liked the name `<date>` to
   represent an instant in time.

I must acknowledge that the development of this library was influenced to some
extent by the Go time package. I like much of what they've done there (except
for the horrific time.Parse API) and I used it as a reference to make sure I
wasn't doing anything too crazy. To a smaller extent I used the Rust and Python
docs as inspiration also.

## High Level Overview

This section contains a brief overview of the `time` library to help you get a
quick feel for how it is organized. See the reference documentation for more
detail.

The `time` library exports a single module, `time` which exports these classes:

* `<time>` - an instant in time, an offset from the Unix Epoch. Has an
  associated time zone for use when converting to the time in a specific
  location on Earth.

* `<duration>` - the elapsed time between two time instants, to nanosecond
  precision.

* `<time-zone>` - A time zone, either "naive" or "aware". (See the next two
  classes.)

* `<naive-zone>` - A time zone that always represents the same offset from
  UTC. The primary example of this is the `$utc` time zone itself.

* `<aware-zone>` - A time zone that may have different offsets from UTC over
  time due to daylight savings time and governmental action. These zones use
  data from the the tzinfo (TODO: link) package.

* `<day>` - Represents a day of the week, with a name and short name.

* `<month>` - Represents a month, January to December, with a name, short name,
  and number from 1 to 12.

The library API can be logically separated into several parts:

* Constructors - `<time>` objects are usually created by calling `time-now`,
  `parse-time`, or by constructing one from components with `make-time(year,
  month, day, ...)`. It is also fine to call `make(<time>)` directly.

* Accessors - for example to extract the number of seconds from a time or the
  number of days in a month.

* Conversions - for converting times and durations to and from strings,
  composing/decomposing them from/into their parts, or converting to a
  different zone.

* Comparisons - the `=`, `<`, and '>' functions work on pairs of times and
  pairs of durations.

* Time arithmetic - the Dylan arithmetic operators are overloaded to work on
  certain combinations of times and durations:

  * _time_ `+` _duration_ **or** _duration_ `+` _time_
  * _time_ `-` _duration_
  * _duration_ `+` _duration_
  * _duration_ `-` _duration_
  * _duration_ `*` _real number_ **or** _real number_ `*` _duration_
  * _duration_ `/` _real number_



system.  2305843009213693951 / (1000000000 * 60 * 60 * 24 * 365.0)

## TODO

*  Platform-specific libraries.

*  Load TZ data for "aware" time zones.

*  Decide how/whether to deal with monotonic clocks here.

*  Leap seconds.
   https://docs.rs/chrono/*/chrono/naive/struct.NaiveTime.html#leap-second-handling

*  Calender operations? Could go in separate module or even library.

*  i18n - ensure that if someone wanted to they could make the days,
   months, and date formats display/parse in non-English languages.
