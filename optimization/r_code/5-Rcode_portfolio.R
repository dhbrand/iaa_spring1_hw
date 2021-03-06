library(quadprog)

setwd("G:\\My Drive\\Spring 1  2017 - Optimization")
port <- read.table("portfolio_r.csv", sep = ",", header = T)
mean.vec <- apply(port, 2, mean)
cov.vec <- cov(port)
Dmat <- 2 * cov.vec
dvec <- rep(0, 5)
Amat <- t(matrix(c(1, 1, 1, 1, 1, mean.vec), nrow = 2, byrow = T))
bvec <- c(1, 0.015)
meq <- 1
ln.model <- solve.QP(Dmat, dvec, Amat, bvec, meq)
ln.names <- c("Computer", "Chemical", "Power", "Auto", "Electronics")

names(ln.model$solution) <- ln.names
ln.model$solution
ln.model$value


ln.model$solution
ln.model$value




################################ Efficient Frontier
##############################################

stocks <- read.table("G:\\My Drive\\Spring 1  2017 - Optimization\\stocks_r.csv", sep = ",", header = T)
temp <- stocks[, 1]
temp2 <- as.Date(temp, "%m/%d/%Y")
year.s <- as.numeric(format(temp2, "%Y"))
month.s <- as.numeric(format(temp2, "%m"))
id <- paste(month.s, year.s, sep = "")
stocks.dat <- cbind(id, stocks[, -1])
alldat <- aggregate(. ~ id, data = stocks.dat, sum)
all.dat2 <- alldat[, -1]
all.dat2 <- all.dat2[, -5]
mean.vec <- apply(all.dat2, 2, mean)
cov.vec <- cov(all.dat2)

Dmat <- 2 * cov.vec
dvec <- rep(0, length(mean.vec))
Amat <- matrix(c(rep(1, length(mean.vec)), mean.vec), nrow = 2, byrow = T)
Amat.2 <- diag(length(mean.vec))
Amat <- t(rbind(Amat, Amat.2))
meq <- 2
param <- seq(0.26, 0.4, by = 0.020)
eff.front.weight <- matrix(nrow = length(param), ncol = length(mean.vec))
eff.front.return <- vector(length = length(param))
eff.front.risk <- param
for (i in 1:length(param))
{
  bvec <- c(1, param[i], rep(0, length(mean.vec)))
  ln.model <- solve.QP(Dmat, dvec, Amat, bvec, meq)
  eff.front.return[i] <- sum(ln.model$solution * mean.vec)
  eff.front.risk[i] <- sqrt(ln.model$value)
  eff.front.weight[i, ] <- ln.model$solution
}
plot(eff.front.risk, eff.front.return, type = "l")
