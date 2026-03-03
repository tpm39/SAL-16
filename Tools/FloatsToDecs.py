
# Convert a list of SAL-16 'Floats' to 'Decimals'

# Copy the SAL-16 'Floats' from the Memory 'Edit Contents ...' Window

# 'Float' to 'Decimal' Conversion
def float_to_dec(val):
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
            dec = '0'
      else:
            # Subnormal
            dec = str(((-1)**sign) * (2**(-14)) *  mantVal)

   # Deal with numbers beyond the Normal/Subnormal limits
   elif exp == 0x1f:
      #  NaN or +/-Infinity - Just return '0'
      dec = '0'
            
   # Deal with normal numbers
   else:
      dec = str(((-1)**sign) * (2**(exp - 15)) * (1 + mantVal))

   return dec


# Main Program

# Copy & Paste the SAL-16 'Floats' here:
str_floats = '''
0000
0000 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 1890
1c90 1ee0 2098 21c0 22e4 2406 249a 252e
25c0 2654 26e8 29b0 2bec 2d14 2e32 2f50
3037 30cf 318d 324b 32f9 3385 33e0 3400
33de 3383 32f8 3248 3188 30c4 300a 2eba
2d8d 2c87 2b5e 29f6 28ce 27bd 2640 250c
2418 22a7 216b 206f 1f4b 1e02 1cf9 1c25
1aea 0000 0000 0000 0000 0000 0000 0000
0000 0000 0000 0000 0000 0000 0000 0000
'''

floats = str_floats.split()

str_decs = ''
for flt in floats:
   flt = int(flt, 16)
   dec = float_to_dec(flt)
   str_decs += dec
   str_decs += ','

# Output the 'Decimals' list
print(str_decs[:-1])

