#zad1
set.seed(123)
x <- round(rnorm(20, 0, 1), 2)
print(x)

x[ (-2 <= x & x <= -1) | (1 <= x & x <= 2)]

length(x[x<0])

length(x[x<0])/ length(x[x>=0])

mean(abs(x))

x[which.min(abs(x))]
x[which.max(abs(x))]

x[which.min(abs(2 - x))]
x[which.max(abs(2 - x))]

x1 <- x - min(x)
x1 / max(x1)

n <- length(x)
y <- character(n)

y[x>=0] <- "nieujemna"
y[x<0] <- "ujemna"
y


z <- rep("duży", n)
z[x<(-1)] <- "mały"
z[abs(x)<= 1] <- "średni"
z

a <- floor(x)
hist(a)

#zad2
# a
x <- rnorm(20, 0, 1); y <- 10*x+2
n <- length(x)
r <- sum((x - mean(x)) * (y - mean(y))/(sd(x) * sd(y)))/(length(x) - 1)
r
cor(x, y, method="pearson")

# b
x <- rnorm(20, 0, 1); y <- -4*x+1
r <- sum((x - mean(x)) * (y - mean(y))/(sd(x) * sd(y)))/(length(x) - 1)
r
cor(x, y, method="pearson")

# c
x <- rnorm(2000, 0, 1); y <- rnorm(2000, 5, 2)
r <- sum((x - mean(x)) * (y - mean(y))/(sd(x) * sd(y)))/(length(x) - 1)
plot(x, y)
r
cor(x, y, method="pearson")

#zad6
arcus_sin <- function(x, m = 1000){
  a <- double(m)
  for (n in 0:m){
    a[n + 1] <- (factorial(2*n)) * x**(2*n + 1)/ (4**n * factorial(n)**2 * (2*n+1))
  }
  sum(a)
}
s <- arcus_sin(0.1)
s
asin(0.1)
