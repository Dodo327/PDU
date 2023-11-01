import math

def even_num(n):
    return True if n % 2 == 0 else False

def sqrt(n):
    return True if math.sqrt(n) == int(math.sqrt(n)) else False

def even_sqrt(n):
    
    return True if even_num(n) & sqrt(n) else False

def sum_of_lists(x, y):
    return (sum(x), sum(y))

def intersect(x, y):
    z = {}
    for el in x:
        if el in y:
            z.append(el)
    
    return z

x = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

print(tuple(filter(even_num, x)))
print(tuple(filter(sqrt, x)))
print(tuple(filter(even_sqrt, x)))