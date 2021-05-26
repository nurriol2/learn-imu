import numpy as np
import matplotlib.pyplot as plt

#number of points in the sequence
N = 10000
#correlation time 
Tc = 1000 #TODO:  make this adjustable 
#array of magnitudes
b = np.zeros(shape=(N,))

for i in range(1, N):
    bdot = (-1/Tc)*b[i-1] + 0.01*np.random.randn(1)
    b[i] = b[i-1]+bdot

t = np.linspace(0, N, N)

plt.plot(t, b)

plt.title("Simulated Bias Instability with Drift")
plt.xlabel("Time (sec)")
plt.ylabel("Noise Magnitude (unit)")
plt.grid(b=True)
plt.show()