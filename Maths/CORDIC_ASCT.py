
# Implementation of the CORDIC algorithm
# to produce plots of ASin, ACos & ATan

import math
import numpy as np
import matplotlib.pyplot as plt

ATANS = [0.78515625, 0.46362305, 0.24499512, 0.12432861,
         0.06240845, 0.03123474, 0.01562500, 0.00781250,
         0.00390625, 0.00195313, 0.00097656, 0.00048828]

CORDIC_K = 0.60742188

CORDIC_VECT_Y = 0
CORDIC_VECT_X = 1

def asct(fn, val):

   match fn:
      case 'asin':
         mode = CORDIC_VECT_Y
         d_cmp = val
         x = [CORDIC_K]
         y = [0.0]
         z = [0.0]

      case 'acos':
         mode = CORDIC_VECT_X
         d_cmp = val
         x = [0.0]
         y = [CORDIC_K]
         z = [-math.pi/2]

      case 'atan':
         mode = CORDIC_VECT_Y
         d_cmp = 0
         x = [1.0]
         y = [val]
         z = [0.0]

      case _:
         raise Exception()

   p = 1
   
   for i in range(len(ATANS)):
      xi = x[-1]
      yi = y[-1]
      zi = z[-1]

      if mode == CORDIC_VECT_Y:
         # Vectoring Mode - minimise error in y
         if yi > d_cmp:
            d = -1
         else:
            d = 1

      else:
         # Vectoring Mode - minimise error in x
         if xi > d_cmp:
            d = 1
         else:
            d = -1

      x.append(xi - (yi * d/p))
      y.append(yi + (xi * d/p))
      z.append(zi - (d * ATANS[i]))

      p *= 2

   if fn in ['asin', 'acos']:
      return -z[-1]
   else:
      return z[-1]


# Plot Stuff ...

fn = input('asin, acos or atan: ')

plt.axhline(y=0, color='lightgrey')
plt.axvline(x=0, color='lightgrey')

xs = np.linspace(-1.0,1.0,100)

cordic_ys = [asct(fn, x) for x in xs]

if fn == 'asin':
   math_ys = [math.asin(x) for x in xs]
   plt.plot(xs, math_ys, 'blue', label='True asin()')
   plt.plot(xs, cordic_ys, 'red', label='CORDIC asin()')

elif fn == 'acos':
   math_ys = [math.acos(x) for x in xs]
   plt.plot(xs, math_ys, 'blue', label='True acos()')
   plt.plot(xs, cordic_ys, 'red', label='CORDIC acos()')

else:
   math_ys = [math.atan(x) for x in xs]
   plt.plot(xs, math_ys, 'blue', label='True atan()')
   plt.plot(xs, cordic_ys, 'red', label='CORDIC atan()')

plt.legend()
plt.show()

