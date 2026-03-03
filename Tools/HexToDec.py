
# Convert a 16 bit Hex number to decimal

try:
    while True:
        num = int(input('Hex: 0x'), base=16)

        if num >= 0x8000:
            num -= 2**16
            
        print(f'Dec: {num}\n')

except:
    print('\nOK - Done\n')
