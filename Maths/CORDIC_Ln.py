
# Implementation of the CORDIC algorithm to produce ln(x)

import math
import numpy as np
import matplotlib.pyplot as plt

def ln(n):
    atanhs = [31.4729237309, 14.6340761545, 7.1996280356,
               3.5856599209,  1.7910762943, 0.8953194209,
               0.4476323847,  0.2238127771, 0.1119059617,
               0.0559529275,  0.0279764571, 0.0139882277]

    x = [n + 1]
    y = [n - 1]
    z = [0.0]
    p = 2

    for i in range(len(atanhs)):
        xi = x[-1]
        yi = y[-1]
        zi = z[-1]

        if yi < 0.0:
            d = 1
        else:
            d = -1
        
        x.append(xi + (yi*d/p))
        y.append(yi + (xi*d/p))
        z.append(zi - (d*atanhs[i]))

        p *= 2

    res = 2 * z[-1] * math.pi / 180.0
    return res


# Plot Stuff ...

plt.axhline(y=0, color='lightgrey')
plt.axvline(x=0, color='lightgrey')

xs = np.linspace(-5.0,0.01,1000)
cordic_ys = [ln(x) for x in xs]

plt.plot(xs, cordic_ys, 'red')

xs = np.linspace(0.01,15.0,1000)
math_ys = [math.log(x) for x in xs]
cordic_ys = [ln(x) for x in xs]

plt.plot(xs, math_ys, 'blue', label='True ln()')
plt.plot(xs, cordic_ys, 'red', label='CORDIC ln()')

plt.legend()
plt.show()

