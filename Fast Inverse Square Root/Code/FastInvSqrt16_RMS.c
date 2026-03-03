
// Get the 'Magic Number' for calculating the Inverse Square Root
// of a 16 bit number - Using an 'RMS' method.

#include <stdio.h>
#include <math.h>

int16_t MY_MAGIC_NUM = 0x59e0;

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
   float x, mult;
   __fp16 y, y_fisr;
   float err, err2_tot;
   float rms, rms_low;
   int nums;

   printf("\nMultiplier: ");
   scanf("%f", &mult);
   printf("\n");

   rms_low = INFINITY;

   for (int mn = 0; mn <= 0xffff; mn+=1) {
      err2_tot = 0.0;

      x = X_MIN;
      nums = 0;
      while (x <= X_MAX) {
         y = 1.0/sqrt(x);
         y_fisr = fisr((__fp16)x, mn);
         err = (float)(y_fisr - y);
         err2_tot += (err * err);
         x *= mult;
         nums++;
      }

      rms = sqrt(err2_tot / nums);
      if (rms < rms_low) {
         rms_low = rms;
         magic_num = mn;
      }

      if (mn == MY_MAGIC_NUM)
         printf("'My' Magic Number:       0x%x, RMS: %12.10f\n", mn, rms);
   }

   printf("Calculated Magic Number: 0x%x, RMS: %12.10f\n(Number of Points Used: %d)\n\n",
          magic_num, rms_low, nums);
}

