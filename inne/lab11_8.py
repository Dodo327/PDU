import numpy as np

def dist(X, y):
    assert X.ndim == 2
    assert y.ndim == 1
    assert X.shape[0] == y.shape[1]
    return np.sqrt(((X - y)**2).sum(axis=1))

x = np.random.normal(2, 1, 20).reshape(5, 4)
y = np.array([1, 2, 3, 4])