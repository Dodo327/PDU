import numpy as np

np.random.seed(6)
x = np.round(np.random.normal(size=20), 2)
y = np.array([None] * len(x))

y[x < -1] = "mały"
y[abs(x) <= 1] = "średni"
y[y == None] = "duży"

print(y)