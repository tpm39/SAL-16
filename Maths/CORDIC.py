
import math

# CORDIC constants
ATANS = [0.78515625, 0.46362305, 0.24499512, 0.12432861,
         0.06240845, 0.03123474, 0.01562500, 0.00781250,
         0.00390625, 0.00195313, 0.00097656, 0.00048828]

CORDIC_K = 0.60742188

CORDIC_ROT    = 0
CORDIC_VECT_Y = 1
CORDIC_VECT_X = 2

# The CORDIC Algorithm
def CORDIC(func, arg):

   match func:
      case 'sin' | 'cos' | 'tan' | 'cosec' | 'sec' | 'cot':
         mode = CORDIC_ROT
         d_cmp = 0
         x = [CORDIC_K]
         y = [0.0]
         z = [arg]

      case 'asin':
         mode = CORDIC_VECT_Y
         d_cmp = arg
         x = [CORDIC_K]
         y = [0.0]
         z = [0.0]

      case 'acos':
         mode = CORDIC_VECT_X
         d_cmp = arg
         x = [0.0]
         y = [CORDIC_K]
         z = [-math.pi/2]

      case 'atan':
         mode = CORDIC_VECT_Y
         d_cmp = 0
         x = [1.0]
         y = [arg]
         z = [0.0]

      case _:
         raise Exception()
      
   p = 1

   for i in range(len(ATANS)):
      xi = x[-1]
      yi = y[-1]
      zi = z[-1]

      if mode == CORDIC_ROT:
         # Rotation Mode - minimise error in z
         if zi > d_cmp:
            d = 1
         else:
            d = -1

      elif mode == CORDIC_VECT_Y:
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

   match func:
      case 'sin':
         return y[-1]

      case 'cos':
         return x[-1]

      case 'tan':
         return y[-1]/x[-1]

      case 'asin' | 'acos':
         return -z[-1]

      case 'atan':
         return z[-1]

      case 'cosec':
         return 1/y[-1]

      case 'sec':
         return 1/x[-1]

      case 'cot':
         return x[-1]/y[-1]

# Main Program
try:
   while True:
      f = input('func: ')
      x = float(input('x: '))

      #if f not in ['asin', 'acos', 'atan']:
      #   x = x * math.pi / 180.0

      res = CORDIC(f, x)

      print(f'{f}({x}) = {res:0.3f}\n')

except:
    print('\nOK - Done\n')

