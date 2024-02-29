#include <time.h>

int c_get_clock_realtime() {
  return CLOCK_REALTIME;
}

int c_get_clock_monotonic_raw() {
#if defined(__APPLE__)
  return CLOCK_MONOTONIC;
#else
  return CLOCK_MONOTONIC_RAW;
#endif
}

struct tm* c_gmtime_r(const time_t* time, struct tm* parts) {
  return gmtime_r(time, parts);
}
