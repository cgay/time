#include <time.h>

int c_get_clock_realtime() {
  return CLOCK_REALTIME;
}

int c_get_clock_monotonic_raw() {
  return CLOCK_MONOTONIC_RAW;
}
