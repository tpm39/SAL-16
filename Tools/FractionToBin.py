
# Convert a fractional number to a fractional binary number

try:
   while True:
      n_flt = float(input('Fraction: '))
      if n_flt >= 1.0 or n_flt < 0.0:
         print('You must enter a number in the range: 0.0 <= x < 1.0\n')
         continue
      
      n_frac = int(n_flt * 2**10)
      print(f'0.{n_frac:010b}\n')   

except:
    print('\n\nOK - Done\n')

