
// Calculate the Inverse Quadratic Root of a 16 bit number

#include <stdio.h>

__fp16 fiqr(__fp16 num)
{
   int16_t MAGIC_NUMBER = 0x4b53;
   
   int16_t i;
   __fp16 x, y;

   x = 0.25 * num;
   y = num;
   i = * (int16_t*) &y;
   i = MAGIC_NUMBER - (i >> 2);
   y = * (__fp16*) &i;
   y = y * (1.25 - ((((x * y) * y) * y) * y));
   y = y * (1.25 - ((((x * y) * y) * y) * y));

   return y;
}

int main()
{
   float x;
   __fp16 y;

   printf("x: ");
   scanf("%f", &x);

   y = fiqr(x);

   printf("1/qdrt(x): %.3f\n", (float)y);
}

