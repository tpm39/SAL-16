
// Calculate the Inverse Square Root of a 16 bit number

#include <stdio.h>

__fp16 fisr(__fp16 num)
{
   int16_t MAGIC_NUMBER = 0x59e0;
   
   int16_t i;
   __fp16 x, y;

   x = 0.5 * num;
   y = num;
   i = * (int16_t*) &y;
   i = MAGIC_NUMBER - (i >> 1);
   y = * (__fp16*) &i;
   y = y * (1.5 - ((x * y) * y));
   y = y * (1.5 - ((x * y) * y));

   return y;
}

int main()
{
   float x;
   __fp16 y;

   printf("x: ");
   scanf("%f", &x);

   y = fisr(x);

   printf("1/sqrt(x): %.3f\n", (float)y);
}

