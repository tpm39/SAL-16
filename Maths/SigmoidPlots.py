
# Used for plotting sigmoid(x) & d/dx[sigmoid(x)] results from SAL-16

import math
import numpy as np
import matplotlib.pyplot as plt

# x axis limits & x increment
# NB: Ensure these match the values in 'Sigmoids.rmg'
START = -10.0
END   =  10.0
X_INC = 0.25

# 'Sigmoids' Functions
def sigmoid(x):
   return 1/(1 + math.exp(-x))

def sigmoidDerivative(x):
   return math.exp(-x) / (1 + math.exp(-x))**2


# Main Program
plt.axhline(y=0, color='lightgrey')
plt.axvline(x=0, color='lightgrey')

# 'Real' Plots
math_xs = np.linspace(START, END, 1000)
sig_math_ys  = [sigmoid(x) for x in math_xs]
sigd_math_ys = [sigmoidDerivative(x) for x in math_xs]

# SAL-16 Plots
num_pts = int(((END - START) / X_INC) + 1)
sal16_xs = [START + X_INC*i for i in range(num_pts)]

# Copy & Paste the sigmoid(x) results from the 'FloatsToDecs.py' output here:
sig_sal16_ys = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0029296875,0.00579833984375,0.008758544921875,
                0.01165771484375,0.01458740234375,0.017486572265625,0.020416259765625,0.023345947265625,
                0.0262451171875,0.0291748046875,0.032073974609375,0.034912109375,0.0595703125,
                0.0841064453125,0.108642578125,0.13330078125,0.1578369140625,0.184326171875,0.22314453125,
                0.269287109375,0.321044921875,0.378173828125,0.438232421875,0.5,0.5625,0.623046875,
                0.6796875,0.7314453125,0.77734375,0.81787109375,0.85205078125,0.88037109375,0.904296875,
                0.92333984375,0.9384765625,0.951171875,0.9609375,0.96875,0.97509765625,0.97998046875,
                0.98388671875,0.9873046875,0.98974609375,0.99169921875,0.9931640625,0.994140625,
                0.9951171875,0.99609375,0.9970703125,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

# Copy & Paste the d/dx[sigmoid(x)] results from the 'FloatsToDecs.py' output here:
sigd_sal16_ys = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.002227783203125,0.00445556640625,0.0067138671875,
                 0.00897216796875,0.01123046875,0.013458251953125,0.015716552734375,0.017974853515625,
                 0.020233154296875,0.0224609375,0.02471923828125,0.0269775390625,0.04443359375,
                 0.0618896484375,0.079345703125,0.0968017578125,0.1142578125,0.1317138671875,
                 0.1502685546875,0.1734619140625,0.1966552734375,0.2178955078125,0.2349853515625,
                 0.24609375,0.25,0.245849609375,0.2347412109375,0.2177734375,0.1962890625,0.1728515625,
                 0.14892578125,0.126220703125,0.1051025390625,0.08673095703125,0.07073974609375,
                 0.05755615234375,0.04656982421875,0.03753662109375,0.0302276611328125,0.0244140625,
                 0.01971435546875,0.0159912109375,0.01299285888671875,0.01058197021484375,
                 0.00865936279296875,0.007122039794921875,0.00586700439453125,0.004856109619140625,
                 0.004047393798828125,0.003376007080078125,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

# sigmoid(x) plots
plt.plot(math_xs, sig_math_ys, 'blue', label='y = sigmoid(x)')
plt.scatter(sal16_xs, sig_sal16_ys, color='red', marker='*', label='SAL-16')

# d/dx[sigmoid(x)] plots
plt.plot(math_xs, sigd_math_ys, 'orange', label='d/dx[sigmoid(x)]')
plt.scatter(sal16_xs, sigd_sal16_ys, color='green', marker='*', label='SAL-16')

plt.legend()
plt.show()

