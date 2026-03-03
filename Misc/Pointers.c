
#include <stdio.h>

int a[3] = {1, 2, 3};
int d = 5;

int main()
{
   int* b;

   b = &a[0];  // or: b = a

   printf("a[1]: %d, b: %d, d: %d, &b: %d\n", a[1], *b, d, b);

   b++; 
   *b = 10;
   d = *b;

   printf("a[1]: %d, b: %d, d: %d, &b: %d\n", a[1], *b, d, b);

   return 0;
}

