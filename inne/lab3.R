#1
x <- function(t){
  k <- max(t)
  n <- length(t)
  M <- matrix(0, n, k)
  M[cbind(1:n, t)] <- 1
  M
}

t <- c(1,2,4,7,3,5)
M<- x(t)

#2
softmax <- function(M){
  Z <- exp(M)
  Z/rowSums(Z)
}

decode <- function(M){
  apply(M, 1, function(z){
    which.min(abs(z-1))
  })
}

M <- matrix(c(5,2,3,4,5,1), 2, 3)
softmax(M)

decode(M)