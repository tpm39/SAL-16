
// Get the 'Magic Number' for calculating the Inverse Square Root
// of a 32 bit number - Using an 'RMS' method.

#include <stdio.h>
#include <math.h>

int32_t ALG_MAGIC_NUM = 0x5f3759df;

int32_t MIN_MAGIC_NUM = 0x5f360000;
int32_t MAX_MAGIC_NUM = 0x5f380000;

float fisr(float num, int32_t magic_num)
{
   int32_t i;
   float x, y;

   x = 0.5 * num;
   y = num;
   i = * (int32_t*) &y;
   i = magic_num - (i >> 1);
   y = * (float*) &i;
   y = y * (1.5 - ((x * y) * y));
   y = y * (1.5 - ((x * y) * y));

   return y;
}

int main()
{
   float x_min, x_max, mult;

   int32_t magic_num;
   float x, y, y_fisr;
   float err, err2_tot;
   float rms, rms_low;
   int nums;

   printf("\nMin x: ");
   scanf("%f", &x_min);
   printf("Max x: ");
   scanf("%f", &x_max);
   printf("Multiplier: ");
   scanf("%f", &mult);
   printf("\n");

   rms_low = INFINITY;

   for (int mn = MIN_MAGIC_NUM; mn <= MAX_MAGIC_NUM; mn += 1) {
      err2_tot = 0.0;

      x = x_min;
      nums = 0;
      while (x <= x_max) {
         y = 1.0/sqrt(x);
         y_fisr = fisr(x, mn);
         err = y_fisr - y;
         err2_tot += (err * err);
         x *= mult;
         nums++;
      }

      rms = sqrt(err2_tot / nums);
      if (rms < rms_low) {
         rms_low = rms;
         magic_num = mn;
      }

      if (mn == ALG_MAGIC_NUM)
         printf("Algorithm's Magic Number: 0x%x, RMS: %12.10f\n", mn, rms);
   }

   printf("Calculated Magic Number:  0x%x, RMS: %12.10f\n(Number of Points Used: %d)\n\n",
          magic_num, rms_low, nums);
}

