
# Convert a decimal number to 16 bit Hex

import math

try:
    while True:
        n_dec = int(input('Dec: '))

        num = n_dec & 0xffff

        if num < 0:
            num = num ^ 0xffff
            num += 1
        
        print(f'\nHex: 0x{num:04x}\n')

except:
    print('\nOK - Done\n')

