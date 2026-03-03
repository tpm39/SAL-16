
import math
import numpy as np
import matplotlib.pyplot as plt

plt.axhline(y=0, color='lightgrey')
plt.axvline(x=0, color='lightgrey')

# exp(x)

#exp_math_xs = np.linspace(-1.05,1.05,1000)  # CORDIC
exp_math_xs = np.linspace(-3.0,3.0,1000)  # Taylor
exp_math_ys = [math.exp(x) for x in exp_math_xs]

exp_cordic_xs = [0.05*i for i in range(-21,22)]
exp_cordic_ys = [0.351,0.369,0.388,0.407,0.428,0.450,0.473,0.497,0.524,0.551,
                 0.578,0.608,0.640,0.671,0.705,0.741,0.779,0.819,0.860,0.905,
                 0.951,0.959,1.053,1.107,1.163,1.222,1.285,1.353,1.422,1.492,
                 1.570,1.649,1.728,1.823,1.918,2.020,2.123,2.232,2.346,2.467,
                 2.596,2.730,2.873]

exp_taylor_xs = [-3.0+0.25*i for i in range(25)]
exp_taylor_ys = [0.362,0.239,0.172,0.150,0.155,0.182,0.226,0.287,0.368,0.473,
                 0.608,0.780,1.000,1.286,1.651,2.121,2.723,3.494,4.484,5.754,
                 7.363,9.422,12.031,15.305,19.422]

#plt.plot(exp_math_xs, exp_math_ys, 'blue', label='True exp()')
#plt.scatter(exp_cordic_xs, exp_cordic_ys, color='red', marker='*', label='CORDIC exp()')
#plt.scatter(exp_taylor_xs, exp_taylor_ys, color='red', marker='*', label='Taylor exp()')

# ln(x)

#ln_math_xs = np.linspace(0.1,8.6,1000)  # CORDIC
ln_math_xs = np.linspace(0.05,6.05,1000)  # Taylor
ln_math_ys = [math.log(x) for x in ln_math_xs]

ln_cordic_xs = [0.1+0.25*i for i in range(35)]
ln_cordic_ys = [-2.117,-1.052,-0.513,-0.164,0.097,0.302,0.472,0.619,0.746,0.859,
                0.958,1.051,1.140,1.217,1.290,1.355,1.418,1.477,1.533,1.586,
                1.637,1.684,1.730,1.773,1.814,1.856,1.895,1.932,1.967,2.004,
                2.035,2.066,2.100,2.117,2.117]

ln_taylor_xs = [0.05+0.25*i for i in range(25)]
ln_taylor_ys = [-2.545,-1.200,-0.598,-0.223,0.050,0.263,0.439,0.589,0.718,0.833,
                0.936,1.029,1.113,1.191,1.262,1.327,1.390,1.446,1.500,1.548,1.596,
                1.638,1.680,1.718,1.756]

plt.plot(ln_math_xs, ln_math_ys, 'blue', label='True ln()')
#plt.scatter(ln_cordic_xs, ln_cordic_ys, color='red', marker='*', label='CORDIC ln()')
plt.scatter(ln_taylor_xs, ln_taylor_ys, color='red', marker='*', label='Taylor ln()')

plt.legend()
plt.show()

