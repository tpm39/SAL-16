
# Implementation of the CORDIC algorithm to produce exp(x)

import math
import numpy as np
import matplotlib.pyplot as plt

def exp(n):
    atanhs = [31.4729237309, 14.6340761545, 7.1996280356,
               3.5856599209,  1.7910762943, 0.8953194209,
               0.4476323847,  0.2238127771, 0.1119059617,
               0.0559529275,  0.0279764571, 0.0139882277]

    K = 1.2051363584464607

    theta = n * 180.0 / math.pi

    x = [K]
    y = [K]
    z = [theta]
    p = 2

    for i in range(len(atanhs)):
        xi = x[-1]
        yi = y[-1]
        zi = z[-1]

        if z[-1] < 0.0:
            d = -1
        else:
            d = 1

        x.append(xi + (yi*d/p))
        y.append(yi + (xi*d/p))
        z.append(zi - (d*atanhs[i]))

        p *= 2

    return x[-1]


# Plot Stuff ...

plt.axhline(y=0, color='lightgrey')
plt.axvline(x=0, color='lightgrey')

xs = np.linspace(-1.5,1.5,1000)
math_ys = [math.exp(x) for x in xs]
cordic_ys = [exp(x) for x in xs]

plt.plot(xs, math_ys, 'blue', label='True exp()')
plt.plot(xs, cordic_ys, 'red', label='CORDIC exp()')

plt.legend()
plt.show()

