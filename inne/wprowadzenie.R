potega <- function(x, p) {
    x ** p
}
# y <- scan(what = integer())
# z <- scan(what = integer())
# a <- potega(y, z)
# print(a)

analiza <- function(w){
    'c'(w)
}
u <- scan(what = double())
#analiza(u)

plot(u, potega(u, 3), type = 1, xlab = 'u', ylab = 'p-ta potega', main = 'Wykres funkcji potega()')

