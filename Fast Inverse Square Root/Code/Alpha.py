
# Get the 'Alpha' adjustment used when calculating the 'Magic Number'
# for the Inverse Square Root Algorithm - Using an 'RMS' method.

import math

PTS = 1000
ALPHAS = 1000000

def calc_rms(alpha):
    err = 0
    for i in range(0, PTS+1):
        x = i/PTS
        ya = math.log2(1 + x)
        ye = x + alpha
        err += (ya - ye)**2

    return math.sqrt(err/PTS)

alpha = None
rms_min = math.inf

#for i in range(0, ALPHAS+1): - Use this line with a lower 'ALPHAS' to hone in first
for i in range(50000, 60000):
    a = i/ALPHAS
    rms = calc_rms(a)
    if rms < rms_min:
        alpha = a
        rms_min = rms

print(alpha)

