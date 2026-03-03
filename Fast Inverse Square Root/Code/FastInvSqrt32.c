
// Calculate the Inverse Square Root of a 32 bit number

#include <stdio.h>

float fisr(float num)
{
   int32_t MAGIC_NUMBER = 0x5f3759df;

   int32_t i;
   float x, y;

   x = 0.5 * num;
   y = num;
   i = * (int32_t*) &y;
   i = MAGIC_NUMBER - (i >> 1);
   y = * (float*) &i;
   y = y * (1.5 - (x * y * y));
   y = y * (1.5 - (x * y * y));

   return y;
}

int main()
{
   float x, y;

   printf("x: ");
   scanf("%f", &x);

   y = fisr(x);

   printf("1/sqrt(x): %.3f\n", y);
}

