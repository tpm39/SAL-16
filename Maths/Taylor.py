
# Implementation of the Taylor Series to
# produce the Sin, Cos & Tan of an angle.

import math

zin = float(input('Angle: '))

zrads = zin * math.pi / 180

sinz = zrads
sinz -= zrads**3 / math.factorial(3)
sinz += zrads**5 / math.factorial(5)
sinz -= zrads**7 / math.factorial(7)

cosz = 1.0
cosz -= zrads**2 / math.factorial(2)
cosz += zrads**4 / math.factorial(4)
cosz -= zrads**6 / math.factorial(6)

tanz = zrads
tanz += zrads**3 / 3
tanz += 2 * zrads**5 / 15
tanz += 17 * zrads**7 / 315

print(f'Sin({zin}) = {sinz:.3f}')
print(f'Cos({zin}) = {cosz:.3f}')
print(f'Tan({zin}) = {tanz:.3f}')
