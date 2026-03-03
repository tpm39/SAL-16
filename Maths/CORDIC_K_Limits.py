
import math

# Circular K

K = 1

for i in range(100):
    a = 1/math.sqrt(1 + (2**(-2*i)))
    K *= a
    
print(f'\nCircular K: {K}')


# Hyperbolic K

import math

A = 1

for i in range(1,100):
    a = math.sqrt(1 - (2**(-2*i)))
    A *= a
    
print(f'\nHyperbolic K: {1/A}\n')

