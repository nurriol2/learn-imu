import numpy as np
import matplotlib.pyplot as plt

#the characterizing coefficient N 
step_size = 0.05

#number of steps
sample_num = 1000

time = np.arange(0, sample_num+1)

#keeping track of all positions throughout the walk
walk = np.zeros((sample_num+1))

#initial position (y-axis) for random walk to begin from
position = 0

#take steps
for step in range(0, sample_num):
    #draw from uniform distribution [0,1)
    r = np.random.rand(1)

    if r<=0.5:
        #step down coeffN units from current position
        position -= step_size
    else:
        #step up coeffN units from current position
        position += step_size

    #update
    walk[step+1] += position

#plot results
plt.plot(time, walk, lw=2)

plt.title("Simulated Random Walk")
plt.xlabel("Time (sec)")
plt.ylabel("Noise Magnitude (unit)")
plt.grid(b=True)
plt.show()
