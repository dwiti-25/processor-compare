// Minimal freestanding runtime shared by all benchmarks: putchar/printf over the testbench MMIO,
// the string/memory functions the benchmarks use, and setStats() for riscv-tests' Dhrystone.
// (Dhrystone brings its own no-op debug_printf.)
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
#include "mmio.h"

int putchar(int c) { mmio_putchar((char)c); return c; }

static void put_uint(unsigned long long v, int base, int width, char pad, int neg)
{
  char buf[24];
  int n = 0;
  do {
    int d = (int)(v % base);
    buf[n++] = (char)(d < 10 ? '0' + d : 'a' + d - 10);
    v /= base;
  } while (v);
  if (neg) buf[n++] = '-';
  while (n < width) { putchar(pad); width--; }
  while (n) putchar(buf[--n]);
}

int vprintf(const char *fmt, va_list ap)
{
  for (; *fmt; fmt++) {
    if (*fmt != '%') { putchar(*fmt); continue; }
    fmt++;
    char pad = ' ';
    int width = 0, lng = 0;
    if (*fmt == '0') { pad = '0'; fmt++; }
    while (*fmt >= '0' && *fmt <= '9') width = width * 10 + (*fmt++ - '0');
    while (*fmt == 'l') { lng++; fmt++; }
    switch (*fmt) {
      case 'd': case 'i': {
        long long v = lng >= 2 ? va_arg(ap, long long) : lng ? va_arg(ap, long) : va_arg(ap, int);
        put_uint(v < 0 ? -(unsigned long long)v : (unsigned long long)v, 10, width, pad, v < 0);
        break;
      }
      case 'u': case 'x': {
        unsigned long long v = lng >= 2 ? va_arg(ap, unsigned long long)
                             : lng ? va_arg(ap, unsigned long) : va_arg(ap, unsigned int);
        put_uint(v, *fmt == 'x' ? 16 : 10, width, pad, 0);
        break;
      }
      case 'c': putchar(va_arg(ap, int)); break;
      case 's': { const char *s = va_arg(ap, const char *); while (*s) putchar(*s++); break; }
      case '%': putchar('%'); break;
      default: putchar('%'); putchar(*fmt); break;
    }
  }
  return 0;
}

int printf(const char *fmt, ...)
{
  va_list ap;
  va_start(ap, fmt);
  vprintf(fmt, ap);
  va_end(ap);
  return 0;
}

void *memcpy(void *d, const void *s, size_t n)
{
  uint8_t *dp = d;
  const uint8_t *sp = s;
  while (n--) *dp++ = *sp++;
  return d;
}

void *memset(void *d, int c, size_t n)
{
  uint8_t *dp = d;
  while (n--) *dp++ = (uint8_t)c;
  return d;
}

char *strcpy(char *d, const char *s)
{
  char *r = d;
  while ((*d++ = *s++)) ;
  return r;
}

int strcmp(const char *a, const char *b)
{
  while (*a && *a == *b) { a++; b++; }
  return (unsigned char)*a - (unsigned char)*b;
}

size_t strlen(const char *s)
{
  size_t n = 0;
  while (s[n]) n++;
  return n;
}

// Benchmark region marker: tells the testbench to count cycles, and reports mcycle/minstret deltas.
static uint32_t stats_cycle, stats_instret;
void setStats(int enable)
{
  if (enable) {
    mmio_mark(1);
    stats_instret = rd_minstret();
    stats_cycle = rd_mcycle();
  } else {
    uint32_t c = rd_mcycle() - stats_cycle;
    uint32_t i = rd_minstret() - stats_instret;
    mmio_mark(0);
    printf("STATS mcycle=%u minstret=%u\n", c, i);
  }
}
