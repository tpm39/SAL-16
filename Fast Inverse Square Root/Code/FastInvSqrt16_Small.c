
// Get the 'Magic Number' for calculating the Inverse Square Root
// of a 16 bit number - Using a 'Smallest Error' method.

#include <stdio.h>
#include <math.h>

__fp16 fisr(__fp16 num, int16_t magic_num)
{
   int16_t i;
   __fp16 x, y;

   x = 0.5 * num;
   y = num;
   i = * (int16_t*) &y;
   i = magic_num - (i >> 1);
   y = * (__fp16*) &i;
   y = y * (1.5 - ((x * y) * y));
   y = y * (1.5 - ((x * y) * y));

   return y;
}

int main()
{
   float X_MIN = 5.961e-8;
   float X_MAX = 65504.0;

   int16_t magic_num;
   int64_t mn_tot;
   float x, mult;
   __fp16 y, y_fisr;
   __fp16 err, err_low;
   int nums;

   printf("\nMultiplier: ");
   scanf("%f", &mult);
   printf("\n");

   x = X_MIN;
   nums = 0;
   mn_tot = 0;

   while (x <= X_MAX) {
      y = 1.0/sqrt(x);
      err_low = INFINITY;
      nums++;

      for (int mn = 0x0000; mn <= 0xffff; mn++) {
         y_fisr = fisr((__fp16)x, mn);
         err = fabsf(y - y_fisr);
         if (err < err_low) {
            err_low = err;
            magic_num = mn;
         }
      }

      y_fisr = fisr((__fp16)x, magic_num);
      printf("x: %14.8f, 1/sqrt(x): %8.3f, FISR(x): %8.3f, MAGIC NUMBER: 0x%x\n", 
             x, (float)y, (float)y_fisr, magic_num);

      mn_tot += magic_num;
      x *= mult;
   }

   printf("\nAverage MAGIC NUMBER: 0x%llx (%d numbers, Multiplier: %0.4f)\n\n",
          mn_tot/nums, nums, mult);   
}

