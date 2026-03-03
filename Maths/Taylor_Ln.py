
# Implementation of the Taylor Series to produce ln(x)

import math
import numpy as np
import matplotlib.pyplot as plt

# Calculate ln(x) using the Taylor Series (up to the 3rd term)
def ln(x):
   res = 0.0
   div = 1.0

   mult = (x - 1.0) / (x + 1.0)
   mult2 = mult * mult
   pow = mult

   for _ in range(1,4):
      res += (pow / div)
      pow *= mult2
      div += 2.0

   return (2.0 * res)


# Plot Stuff ...

plt.axhline(y=0, color='lightgrey')
plt.axvline(x=0, color='lightgrey')

xs = np.linspace(0.05,6.0,1000)
math_ys = [math.log(x) for x in xs]
cordic_ys = [ln(x) for x in xs]

plt.plot(xs, math_ys, 'blue', label='True ln()')
plt.plot(xs, cordic_ys, 'red', label='Taylor ln()')

plt.legend()
plt.show()

