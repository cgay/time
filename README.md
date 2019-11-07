# A Time Library for Dylan

This library is intended to be an improvement on the Open Dylan `date` library
for several reasons:

*  More complete -- it has (or will have) full time zone support.
*  More efficient -- each `<time>` instance uses far less memory.
*  More precision -- nanoseconds rather than microseconds.
*  Better name -- "time" is better than "date". You heard it here first.

I should acknowledge that the development of this library was influenced to
some extent by the Go time package. I like much of what they've done there
(except for the horrific time.Parse API) and I used it as a reference to make
sure I wasn't doing anything too crazy. To a smaller extent I used the Rust
docs as a reference also.

## TODO

*  Platform-specific libraries.

*  Load TZ data for "aware" time zones.

*  Decide how/whether to deal with monotonic clocks here.

*  Leap seconds.
   https://docs.rs/chrono/*/chrono/naive/struct.NaiveTime.html#leap-second-handling

*  Calender operations? Could go in separate module or even library.

*  i18n - ensure that if someone wanted to they could make the days,
   months, and date formats display/parse in non-English languages.
