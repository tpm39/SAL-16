
# Implementation of the CORDIC algorithm
# to produce plots of Sin, Cos & Tan

import math
import numpy as np
import matplotlib.pyplot as plt

ATANS = [0.78515625, 0.46362305, 0.24499512, 0.12432861,
         0.06240845, 0.03123474, 0.01562500, 0.00781250,
         0.00390625, 0.00195313, 0.00097656, 0.00048828]

K = 0.60742188

def sct(fn, ang):
   x = [K]
   y = [0.0]
   z = [ang * math.pi/180.0]
   p = 1

   for i in range(len(ATANS)):
      xi = x[-1]
      yi = y[-1]
      zi = z[-1]

      if zi > 0:
         d = 1
      else:
         d = -1

      x.append(xi - (yi * d/p))
      y.append(yi + (xi * d/p))
      z.append(zi - (d * ATANS[i]))

      p *= 2

   if fn == 'sin':
      return y[-1]
   elif fn == 'cos':
      return x[-1]
   else:
      return y[-1]/x[-1]


# Plot Stuff ...

fn = input('sin, cos or tan: ')

plt.axhline(y=0, color='lightgrey')
plt.axvline(x=0, color='lightgrey')

if fn == 'tan':
   xs = np.linspace(0.0,85.0,1000)
else:
   xs = np.linspace(0.0,90.0,1000)

cordic_ys = [sct(fn, x) for x in xs]

if fn == 'sin':
   math_ys = [math.sin(x * math.pi/180.0) for x in xs]
   plt.plot(xs, math_ys, 'blue', label='True sin()')
   plt.plot(xs, cordic_ys, 'red', label='CORDIC sin()')

elif fn == 'cos':
   math_ys = [math.cos(x * math.pi/180.0) for x in xs]
   plt.plot(xs, math_ys, 'blue', label='True cos()')
   plt.plot(xs, cordic_ys, 'red', label='CORDIC cos()')

else:
   math_ys = [math.tan(x * math.pi/180.0) for x in xs]
   plt.plot(xs, math_ys, 'blue', label='True tan()')
   plt.plot(xs, cordic_ys, 'red', label='CORDIC tan()')

plt.legend()
plt.show()

