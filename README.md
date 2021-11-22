# A Time Library for Dylan

**Current status as of Oct 2021:**

*  Most APIs work, but on Linux only.
*  No TZ data yet so only naive time zones work.
*  Needs more tests.
*  No monotonic clock support yet.

This library is intended to be an improvement on the Open Dylan `date` library
for several reasons:

*  More complete -- it will have full time zone support.
*  More efficient -- each `<time>` instance uses far less memory.
*  More precision -- nanoseconds rather than microseconds.
*  Better naming -- What can I say? I just never liked the name `<date>` to
   represent an instant in time.

The development of this library was influenced to some extent by the time
libraries in Go, Common Lisp (local-time), Python, and Rust, in about that
order. I used them as a reference to make sure I wasn't doing anything too
crazy.

## High Level Overview

NOTE: The first version of this library assumes 64-bit integers. The
contortions necessary to make it work on 32-bit were more than I wanted to deal
with. My plan is to make that work by using `<double-integer>` on 32-bit
architectures, but I don't want to pay the price in speed for doing that on
the more common 64-bit platforms.

This section contains a brief overview of the `time` library to help you get a
quick feel for how it is organized. See the reference documentation for more
detail.

The `time` library exports a single module, `time` which exports these classes:

* `<time>` - an instant in time, an offset from the Unix Epoch. Has an
  associated time zone for use when converting to the time in a specific
  location on Earth.

* `<duration>` - the elapsed time between two time instants, to nanosecond
  precision.

* `<zone>` - A time zone, either "naive" or "aware". (See the next two
  classes.)

* `<naive-zone>` - A time zone that always represents the same offset from
  UTC. The primary example of this is the `$utc` time zone itself.

* `<aware-zone>` - A time zone that may have different abbreviations and
  offsets from UTC over time due to daylight savings time and governmental
  action. These zones use data from the the tzinfo (TODO: link) package.

* `<day>` - Represents a day of the week, with a name and short name.

* `<month>` - Represents a month, January to December, with a name, short name,
  and number from 1 to 12.

The library API can be logically separated into several parts:

* Constructors - `<time>` objects are usually created by calling `time-now`,
  `parse-time`, or by constructing one from components with `compose-time(year,
  month, day, ...)`. It is also fine to call `make(<time>)` directly.

* Accessors - for example to extract the number of seconds from a time or the
  number of days in a month.

* Conversions - for converting times and durations to and from strings,
  composing/decomposing them from/into their parts, or converting to a
  different zone.

* Comparisons - the `=`, `<`, and `>` functions work on pairs of times and
  pairs of durations.

* Arithmetic - the Dylan arithmetic operators are overloaded to work on
  combinations of times and durations for which it makes logical sense:

  * _time_ `+` _duration_ **or** _duration_ `+` _time_
  * _time_ `-` _duration_
  * _duration_ `+` _duration_
  * _duration_ `-` _duration_
  * _duration_ `*` _real number_ **or** _real number_ `*` _duration_
  * _duration_ `/` _real number_


## Code Organization

* For each file named `foo.dylan` there is a corresponding file named
  `foo-test.dylan` containing unit tests. Unit tests are mainly written for the
  public interfaces, but a few internals are exported from the `%time` module
  to enable verification of results.

* For each exported class I try to keep the methods for initialization (`make`,
  `initialize`) immediately after the class definition. Then the generic
  functions that apply only to that class. Then implementation methods.


## TODO

* Platform-specific libraries.

* Like Rust's time::Instant, uses monotonic clock: `define class <instant>
  (<abstract-time>)` Is this needed?

*  `<date>`, `<naive-date>`, `<time-of-day>`?

*  Load TZ data for "aware" time zones.

*  Decide how/whether to deal with monotonic clocks here.

*  Leap seconds.
   https://docs.rs/chrono/*/chrono/naive/struct.NaiveTime.html#leap-second-handling

*  Calender operations? Could go in separate module or even library.

*  i18n - ensure that if someone wanted to they could make the days,
   months, and date formats display/parse in non-English languages.

* The JavaScript Luxon library has some good API
  ideas. https://moment.github.io/luxon/#/tour In particular it would be nice to support
  intervals (time ranges), and the ISO duration format etc. It also has a nice discussion
  of time zones and some do's and don'ts.

## References

* [RFC2822, Internet Message Format, Date and Time Specification](https://tools.ietf.org/html/rfc2822#page-14)
* [RFC5322, Internet Message Format, Date and Time Specification](https://tools.ietf.org/html/rfc5322#page-14)
* [RFC3339, Date and Time on the Internet: Timestamps](https://tools.ietf.org/html/rfc3339)
* [chrono-Compatible Low-Level Date Algorithms](http://howardhinnant.github.io/date_algorithms.html)
* [Discussion on julia-dev
  group](https://groups.google.com/g/julia-dev/c/YlriSMrVTVs/m/cgf7P8xXzB8J?pli=1) is
  very enlightening about the distinctions between various time concepts.
* [This blog post](https://codeblog.jonskeet.uk/2010/12/01/the-joys-of-date-time-arithmetic/)
  on some of the oddities of date/time arithmetic.
* [RFC 8536, TZif format](https://tools.ietf.org/html/rfc8536)
* Calendrical Calculations -- The Ultimate Edition -- by Reingold and Dershowitz
* https://stackoverflow.com/questions/11188621/how-can-i-convert-seconds-since-the-epoch-to-hours-minutes-seconds-in-java/11197532#11197532
* https://stackoverflow.com/questions/7960318/math-to-convert-seconds-since-1970-into-date-and-vice-versa
