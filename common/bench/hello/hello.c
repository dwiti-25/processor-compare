// Smoke test: prints a line and exercises mul/div and a C-extension-heavy loop.
#include "util.h"
int main(void)
{
  volatile int a = 7, b = 6;
  int sum = 0;
  for (int i = 0; i < 100; i++) sum += i * a / b;
  printf("Hello from RISC-V! 7*6=%d sum=%d\n", a * b, sum);
  return (a * b == 42 && sum == 5734) ? 0 : 1;
}
