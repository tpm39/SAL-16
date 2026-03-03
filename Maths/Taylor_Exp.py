
# Implementation of the Taylor Series to produce exp(x)

import math
import numpy as np
import matplotlib.pyplot as plt

# Calculate exp(x) using the Taylor Series (up to the 6th term)
def exp(x):
   pow = 1.0
   fact = 1.0
   res = 1.0
   f = 1.0

   for i in range(1,7):
      pow *= x
      fact *= f 
      res += (pow / fact)
      f += 1.0

   return res


# Plot Stuff ...

plt.axhline(y=0, color='lightgrey')
plt.axvline(x=0, color='lightgrey')

xs = np.linspace(-3,3,1000)
math_ys = [math.exp(x) for x in xs]
cordic_ys = [exp(x) for x in xs]

plt.plot(xs, math_ys, 'blue', label='True exp()')
plt.plot(xs, cordic_ys, 'red', label='Taylor exp()')

plt.legend()
plt.show()

