
# This class provides a Floating Point Unit for the Emulator

import math

class FPU():
   # Valid operations
   ADD      = 0
   SUBTRACT = 1
   MULTIPLY = 2
   DIVIDE   = 3
   SQRT     = 4
   SIN      = 5
   COS      = 6
   TAN      = 7

   # NaN & Inf's
   NAN     = 0x7e00
   POS_INF = 0x7c00
   NEG_INF = 0xfc00

   # Normal & subnormal limits
   HIGH_NORMAL    =  65504
   LOW_NORMAL     = -65504
   HIGH_SUBNORMAL =  5.960464478e-8
   LOW_SUBNORMAL  = -5.960464478e-8

   # CORDIC constants
   ATANS = [45.000000, 26.562500, 14.039062,
             7.125000,  3.576171,  1.790039,
             0.895019,  0.447509,  0.223754,
             0.111877,  0.055938,  0.027969]

   CORIDC_K = 0.607252

   DEGS_90 = 0x55a0
   DEGS_85 = 0x5550
   DEGS_5  = 0x4500
   DEGS_0  = 0x0000


   # Reset everything on initialisation
   def __init__(self):
      self.x_hex = 0x0000
      self.y_hex = 0x0000
      self.UNF = False
      self.OVF = False
      self.INF = False
      self.NaN = False
   
   # Set the necessary flags after a calculation
   def set_flags(self, val, op):
      self.UNF = False
      self.OVF = False
      self.INF = False
      self.NaN = False

      if val == 'NaN':
         self.NaN = True
      elif val == '+Inf' or val == '-Inf':
         self.INF = True
         if op == FPU.ADD or op == FPU.SUBTRACT or \
            op == FPU.MULTIPLY or (op == FPU.DIVIDE and self.y_hex > 0x0000):
            self.OVF = True
      elif val == '+0' or val == '-0':
         if op == FPU.MULTIPLY or op == FPU.DIVIDE:
            self.UNF = True

   # Get the current state of the flags
   def get_flags(self):
       return (self.UNF, self.OVF, self.INF, self.NaN)

   # Perform the requested calculation: 'x op y', or 'op x'
   def calculate(self, op, x, y=0x0000):
      self.x_hex = x
      self.y_hex = y

      # do_calc() requires x & y as strings
      x_dec = FPU.hex_to_dec(self, x)
      y_dec = FPU.hex_to_dec(self, y)

      z_dec = FPU.do_calc(self, op, x_dec, y_dec)

      FPU.set_flags(self, z_dec, op)

      return FPU.dec_to_hex(self, z_dec)
       
   # Convert a hex floating point number to a decimal string
   def hex_to_dec(self, val):
      # Extract the sign bit, exponent & mantissa
      sign = (val & 0x8000) >> 15
      exp = (val & 0x7c00) >> 10
      mant = (val & 0x03ff)
      mantStr = f'{mant:010b}'

      # Convert the mantissa to its floating point value
      mantVal = 0
      for i in range(10):
         if mantStr[i] == '1':
               mantVal += 1/(2**(i+1))

      # Deal with Subnormal numbers & zero
      if exp == 0:
         if mant == 0:
               # Zero
               if sign == 0:
                  dec = '+0'
               else:
                  dec = '-0'
         else:
               # Subnormal
               dec = str(((-1)**sign) * (2**(-14)) *  mantVal)

      # Deal with numbers beyond the Normal/Subnormal limits
      elif exp == 0x1f:
         if mant == 0:
               # +/- Infinity
               if sign == 0:
                  dec = '+Inf'
               else:
                  dec = '-Inf'
         else:
               # NaN
               dec = 'NaN'
               
      # Deal with normal numbers
      else:
         dec = str(((-1)**sign) * (2**(exp - 15)) * (1 + mantVal))

      return dec

   # Convert a decimal string to a hex floating point number
   def dec_to_hex(self, val):

      if val == '0':
         val = '+0'

      if val == 'Inf':
         val = '+Inf'

      try:
         # Get the value
         val = float(val)

         if math.isnan(val) or val == float('inf') or val == float('-inf'):
            raise Exception()         

         # Get the sign bit
         if val < 0:
            val = abs(val)
            sign = '1'
         else:
            sign = '0'
         
         # Get the exponent
         exp = 15
         
         # If the number's 2 or above keep dividing by 2 until it's not.
         # While doing this the exponent must be incremented for each division,
         # so that val * (2**exp) remains equal to the initial number.
         while val >= 2:
            val /= 2
            exp += 1

         # Numbers beyond the normal range are infinite
         if exp > 30:
            if sign == '0':
               return FPU.POS_INF
            else:
               return FPU.NEG_INF

         # If the number's below 1 keep multiplying by 2 until it's not.
         # While doing this the exponent must be decremented for each multiplication,
         # so that val * (2**exp) remains equal to the initial number.
         while val < 1:
            val *= 2
            exp -= 1
            if exp == 0:
               # It's a subnormal number - exponent can't be lowered further
               val /= 2
               break

         # Get the mantissa
         mant = ''
         
         # Get rid of the leading '1' for normal numbers
         if exp != 0:
            val -= 1
               
         for _ in range(21):
            val = 2 * val
            if val >= 1:
               val -= 1
               mant += '1'
            else:
               mant += '0'

         # Perform rounding if necessary (round to nearest even for 0.5)
         if (mant[9] == '0' and mant[10] == '1' and '1' in mant[11:]) or \
         (mant[9] == '1' and mant[10] == '1'):
            mant = mant[:10]
            mantInt = int(mant, 2) + 1
            if hex(mantInt) == '0x400':
               mant = '0' * 10
               exp += 1
            else:
               mant = f'{mantInt:010b}'
         else:
            mant = mant[:10]
      
         bin_str = sign + f'{exp:05b}' + mant
         return int(bin_str, 2)
      
      except:
         # The value is infinite or invalid
         if val == float('inf'):
            return FPU.POS_INF
         elif val == float('-inf'):
            return FPU.NEG_INF
         else:
            return FPU.NAN

   # Perform the required operation
   def do_calc(self, op, x, y=''):
         
      # Deal with special cases first:
      
      # Anything involving NaN results in NaN
      if x == 'NaN' or y == 'NaN':
         return 'NaN'

      # Deal with SQRTs
      if op == FPU.SQRT: 
         # Square SQRT of negative numbers results in NaN
         if x.startswith('-'):
            return 'NaN'

         # Square SQRT of Inf = Inf
         if x == '+Inf':
            return '+Inf'

      # Deal with Infinities
      if 'Inf' in x or 'Inf' in y:

         # Division
         if (op == FPU.DIVIDE):
            # Inf / Inf = NaN
            if 'Inf' in x and 'Inf' in y:
               return 'NaN'
               
            # Inf / x = 0
            if 'Inf' in x:
               if x.startswith('-'):
                  if y.startswith('-'):
                     return '+Inf'
                  else:
                     return '-Inf'
               else:
                  if y.startswith('-'):
                     return '-Inf'
                  else:
                     return '+Inf'

            # x / Inf = 0
            else:
               if x.startswith('-'):
                  if y.startswith('-'):
                        return '+0'
                  else:
                        return '-0'
               else:
                  if y.startswith('-'):
                        return '-0'
                  else:
                        return '+0'

         # Multiplication
         if (op == FPU.MULTIPLY):

            # Inf * 0 = NaN
            if 'Inf' in x and (y == '+0' or y == '-0'):
               return 'NaN'

            # 0 * Inf = NaN
            if (x == '+0' or x == '-0') and 'Inf' in y:
               return 'NaN'

            # Inf * x = Inf
            # x * Inf = Inf
            if x.startswith('-'):
               if y.startswith('-'):
                  return '+Inf'
               else:
                  return '-Inf'
            else:
               if y.startswith('-'):
                  return '-Inf'
               else:
                  return '+Inf'

         # Sin/Cos/Tan
         if (op == FPU.SIN) or (op == FPU.COS) or (op == FPU.TAN):
               return 'NaN'

         # Addition/Subtraction

         # Inf + Inf = Inf : -Inf - Inf = -Inf : Inf - Inf = NaN
         if ('Inf' in x) and ('Inf' in y):
            if x[0] == y[0]:
               if op == FPU.ADD:
                  if x.startswith('+'):
                     return '+Inf'
                  else:
                     return '-Inf'                         
               else:
                  return 'NaN'
            else:
               if op == FPU.ADD:
                  return 'NaN'
               else:
                  if x.startswith('+'):
                     return '+Inf'
                  else:
                     return '-Inf'                         

         # Inf + x = Inf
         if ('Inf' in x):
            if x.startswith('+'):
               return '+Inf'
            else:
               return '-Inf'                         

         # x - Inf = -Inf
         if 'Inf' in y:
            if op == FPU.ADD:
               if (y[0] == '+'):
                  return '-Inf'
               else:
                  return '+Inf'
            else:
               if (y[0] == '-'):
                  return '+Inf'
               else:
                  return '-Inf'

      # Deal with: x / 0
      if op == FPU.DIVIDE and (y == '+0' or y == '-0'):
         if x == '+0' or x == '-0':
            return 'NaN'

         if x.startswith('-'):
            if y.startswith('+'):
               return '-Inf'
            else:
               return '+Inf'
         else:
            if y.startswith('+'):
               return '+Inf'
            else:
               return '-Inf'

      # Extract the sign bit, exponent & mantissa of X
      valX = self.x_hex
      signX = (valX & 0x8000) >> 15
      expX = (valX & 0x7c00) >> 10
      mantX = (valX & 0x03ff)
      mantStrX = f'{mantX:010b}'

      # Convert the mantissa of X to its floating point value
      mantValX = 0
      for i in range(10):
         if mantStrX[i] == '1':
               mantValX += 1/(2**(i+1))

      # Update the exponent & mantissa if it's a subnormal number > 0
      if expX == 0:
         valX = ((-1)**signX) * (2**(-14)) * (mantValX)
      else:
         valX = ((-1)**signX) * (2**(expX-15)) * (1 + mantValX)
         
      # Extract the sign bit, exponent & mantissa of Y
      #valY = y #int(y, 16)
      valY = self.y_hex
      signY = (valY & 0x8000) >> 15
      expY = (valY & 0x7c00) >> 10
      mantY = (valY & 0x03ff)
      mantStrY = f'{mantY:010b}'

      # Convert the mantissa of Y to its floating point value
      mantValY = 0
      for i in range(10):
         if mantStrY[i] == '1':
               mantValY += 1/(2**(i+1))

      # Update the exponent & mantissa if it's a subnormal number > 0
      if expY == 0:
         valY = ((-1)**signY) * (2**(-14)) * (mantValY)
      else:
         valY = ((-1)**signY) * (2**(expY-15)) * (1 + mantValY)
         
      try:
         # Do the calculation
         if op == FPU.ADD:
               if (expX - expY) > 11:
                  valZ = valX
               elif (expY - expX) > 11:
                  valZ = valY
               else:
                  valZ = valX + valY
         
         elif op == FPU.SUBTRACT:
               if (expX - expY) > 11:
                  valZ = valX
               elif (expY - expX) > 11:
                  valZ = -valY
               else:
                  valZ = valX - valY

         elif op == FPU.MULTIPLY:
               valZ = valX * valY

         elif op == FPU.DIVIDE:
               valZ = valX / valY

         elif op == FPU.SQRT:
               valZ = math.sqrt(valX)

         elif op == FPU.SIN:
               if self.x_hex > FPU.DEGS_90:
                  return 'NaN'
               else:
                  valZ,_,_ = FPU.CORDIC(self, valX)

         elif op == FPU.COS:
               if self.x_hex > FPU.DEGS_90:
                  return 'NaN'
               else:
                  _,valZ,_ = FPU.CORDIC(self, valX)

         elif op == FPU.TAN:
               if self.x_hex > FPU.DEGS_90:
                  return 'NaN'
               elif self.x_hex == FPU.DEGS_90:
                  return '+Inf'
               else:
                  _,_,valZ = FPU.CORDIC(self, valX)

      except:
         # The result is 'NaN' if the calculation fails
         return 'NaN'

      # Adjust the result if it's outwith the normal/subnormal limits
      if valZ > FPU.HIGH_NORMAL:
         return '+Inf'
         
      elif valZ < FPU.LOW_NORMAL:
         return '-Inf'
         
      elif (valZ < FPU.HIGH_SUBNORMAL) and (valZ > 0):
         return '+0'
         
      elif (valZ > FPU.LOW_SUBNORMAL) and (valZ < 0):
         return '-0'
         
      else:
         return str(valZ)

   # CORDIC algorithm for Sin/Cos/Tan with: 0 <= theta <= 90 degs
   def CORDIC(self, theta):
      x = [FPU.CORIDC_K]
      y = [0.0]
      z = [0.0]
      p = 1

      for i in range(len(FPU.ATANS)):
         xi = x[-1]
         yi = y[-1]
         zi = z[-1]

         if zi > theta:
            d = 1
         else:
            d = -1
         
         x.append(xi - (yi * d/p))
         y.append(yi + (xi * d/p))
         z.append(zi - (d * FPU.ATANS[i]))

         p *= 2

      if self.x_hex == FPU.DEGS_90:
         # theta = 90
         x = [0.0]
         y = [-1.0]
      elif self.x_hex > FPU.DEGS_85:
         # theta > 85
         y = [-1.0]
      elif self.x_hex == FPU.DEGS_0:
         # theta = 0
         x = [1.0]
         y = [0.0]
      elif self.x_hex < FPU.DEGS_5:
         # theta < 5
         x = [1.0]

      sin = -y[-1]
      cos = x[-1]
      if x[-1] == 0.0:
         tan = math.inf
      else:
         tan = -y[-1]/x[-1]

      # Return (sin, cos, tan)
      return (sin, cos, tan)

