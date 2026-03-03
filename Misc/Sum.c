
#include <stdio.h>

int x[5];

int sum(int* a, int n)
{
   int s = 0;
   for (int i = 0; i < n; i++)
      s += a[i];
   return s;
}

int main()
{
   int y[] = {1,2,3,4};
   int z = sum(y,4);
   int* ptr = y;
   x[0] = 1;
   x[4] = 5;

   printf("A: %i, B: %i\n", *(y+2), y[0]);
}

