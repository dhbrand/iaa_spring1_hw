#----------------------------------#
#           Case Study on          #
#       Portfolio Optimization     #
#                                  #
#           Dr Aric LaBarr         #
#----------------------------------#

# Needed Libraries for Analysis #
library(graphics)
library(quantmod)
library(TTR)
library(ks)
library(scales)
library(forecast)
library(aTSA)
library(ccgarch)
library(fGarch)
library(rugarch)

# Load Stock Data #
tickers <- c("AAPL", "MSFT", "EBAY", "GOOGL", "^DJI")

getSymbols(tickers)

# Convert Data and Calculate Returns - Historical #
stocks_h <- cbind(
  AAPL[, 4],
  MSFT[, 4],
  EBAY[, 4],
  GOOGL[, 4]
)

stocks_h$msft_r <- periodReturn(stocks_h$MSFT.Close, period = "daily")
stocks_h$aapl_r <- periodReturn(stocks_h$AAPL.Close, period = "daily")
stocks_h$ebay_r <- periodReturn(stocks_h$EBAY.Close, period = "daily")
stocks_h$googl_r <- periodReturn(stocks_h$GOOGL.Close, period = "daily")

stocks_h <- stocks_h["2018-02-01/2019-02-01"]

write.zoo(stocks_h, file = "financial_analytics/data/stocks_h.csv", sep = ",")

# Calcualte Historical Mean and Variance #
cov_h <- cov(stocks_h[, 5:8])

means_h <- colMeans(stocks_h[, 5:8])

# Optimize the Portfolio - Historical #
f <- function(x) x[1] * cov_h[1, 1] * x[1] + x[1] * cov_h[1, 2] * x[2] + x[1] * cov_h[1, 3] * x[3] + x[1] * cov_h[1, 4] * x[4] +
    x[2] * cov_h[2, 1] * x[1] + x[2] * cov_h[2, 2] * x[2] + x[2] * cov_h[2, 3] * x[3] + x[2] * cov_h[2, 4] * x[4] +
    x[3] * cov_h[3, 1] * x[1] + x[3] * cov_h[3, 2] * x[2] + x[3] * cov_h[3, 3] * x[3] + x[3] * cov_h[3, 4] * x[4] +
    x[4] * cov_h[4, 1] * x[1] + x[4] * cov_h[4, 2] * x[2] + x[4] * cov_h[4, 3] * x[3] + x[4] * cov_h[4, 4] * x[4]

theta <- c(0.48, 0.01, 0.015, 0.49)

ui <- rbind(
  c(1, 0, 0, 0),
  c(0, 1, 0, 0),
  c(0, 0, 1, 0),
  c(0, 0, 0, 1),
  c(-1, -1, -1, -1),
  c(1, 1, 1, 1),
  c(means_h)
)
ci <- c(
  0,
  0,
  0,
  0,
  -1,
  0.99,
  0.0002
) # 5.04% Annual Return Spread to Daily #

port_opt <- constrOptim(theta = theta, f = f, ui = ui, ci = ci, grad = NULL)

port_weights_h <- port_opt$par
port_var_h <- port_opt$value
names(port_weights_h) <- names(means_h)
final_h <- round(port_weights_h * 100, 2)

# Convert Data and Calculate Returns - CAPM #
stocks_f <- cbind(
  to.weekly(AAPL)[, 4],
  to.weekly(MSFT)[, 4],
  to.weekly(EBAY)[, 4],
  to.weekly(GOOGL)[, 4],
  to.weekly(DJI)[, 4]
)

stocks_f$msft_r <- periodReturn(stocks_f$MSFT.Close, period = "weekly")
stocks_f$aapl_r <- periodReturn(stocks_f$AAPL.Close, period = "weekly")
stocks_f$ebay_r <- periodReturn(stocks_f$EBAY.Close, period = "weekly")
stocks_f$googl_r <- periodReturn(stocks_f$GOOGL.Close, period = "weekly")
stocks_f$dji_r <- periodReturn(stocks_f$DJI.Close, period = "weekly")

stocks_f <- stocks_f["2014-02-01/2019-02-01"]

write.zoo(stocks_f, file = "financial_analytics/data/stocks_f.csv", sep = ",")

# Single Factor Models #
results <- lapply(6:9, function(x) lm(stocks_f[, x] ~ stocks_f[, 10]))
names(results) <- c("MSFT", "AAPL", "EBAY", "GOOGL")

coefs <- sapply(results, coef, FUN.VALUE = matrix(nrow = 2, ncol = 4))

alphas <- coefs[1, ]
betas <- coefs[2, ]

sys_risk <- betas * sd(stocks_f$dji_r)

anova_res <- lapply(results, anova)

spec_risk <- NULL
for (i in names(results)) {
  spec_risk[i] <- sqrt(anova_res[[i]][2, 3])
}

CAPM_results <- rbind(alphas, betas, sys_risk, spec_risk)

# Optimize the Portfolio - CAPM #
f <- function(x) x[1] * alphas[1] + x[2] * alphas[2] + x[3] * alphas[3] + x[4] * alphas[4] +
    var(stocks_f$dji_r) * (x[1] * betas[1] + x[2] * betas[2] + x[3] * betas[3] + x[4] * betas[4])^2

theta <- c(0.48, 0.01, 0.015, 0.49)

ui <- rbind(
  c(1, 0, 0, 0),
  c(0, 1, 0, 0),
  c(0, 0, 1, 0),
  c(0, 0, 0, 1),
  c(-1, -1, -1, -1),
  c(1, 1, 1, 1),
  c(alphas + mean(stocks_f$dji_r) * betas)
)
ci <- c(
  0,
  0,
  0,
  0,
  -1,
  0.99,
  0.00097
) # 5.04% Annual Return Spread to Weekly #

port_opt <- constrOptim(theta = theta, f = f, ui = ui, ci = ci, grad = NULL)

port_weights_f <- port_opt$par
port_var_f <- port_opt$value
names(port_weights_f) <- names(results)
final_f <- round(port_weights_f * 100, 2)

# Convert Data and Calculate Returns - GARCH #
stocks_g <- cbind(
  AAPL[, 4],
  MSFT[, 4],
  EBAY[, 4],
  GOOGL[, 4]
)

stocks_g$msft_r <- periodReturn(stocks_g$MSFT.Close, period = "daily")
stocks_g$aapl_r <- periodReturn(stocks_g$AAPL.Close, period = "daily")
stocks_g$ebay_r <- periodReturn(stocks_g$EBAY.Close, period = "daily")
stocks_g$googl_r <- periodReturn(stocks_g$GOOGL.Close, period = "daily")

stocks_g <- stocks_g["2017-02-01/2019-02-01"]

write.zoo(stocks_g, file = "financial_analytics/data/stocks_g.csv", sep = ",")

# Calcualte Historical Mean and Variance #
cov_g <- cov(stocks_g[, 5:8])

means_g <- colMeans(stocks_g[, 5:8])

# Estimate GARCH Models #
Skew.GARCH.t <- garchFit(
  formula = ~ garch(1, 1), data = stocks_g$msft_r,
  cond.dist = "sstd", include.mean = FALSE
)
summary(Skew.GARCH.t)

msft_for <- median(head(predict(Skew.GARCH.t), 5)[, 3])^2

Skew.GARCH.t <- garchFit(
  formula = ~ garch(1, 1), data = stocks_g$aapl_r,
  cond.dist = "sstd", include.mean = FALSE
)
summary(Skew.GARCH.t)

aapl_for <- median(head(predict(Skew.GARCH.t), 5)[, 3])^2

Skew.GARCH.t <- garchFit(
  formula = ~ garch(1, 1), data = stocks_g$ebay_r,
  cond.dist = "sstd", include.mean = FALSE
)
summary(Skew.GARCH.t)

ebay_for <- median(head(predict(Skew.GARCH.t), 5)[, 3])^2

Skew.GARCH.t <- garchFit(
  formula = ~ garch(1, 1), data = stocks_g$googl_r,
  cond.dist = "sstd", include.mean = FALSE
)
summary(Skew.GARCH.t)

googl_for <- median(head(predict(Skew.GARCH.t), 5)[, 3])^2

# Optimize the Portfolio - GARCH #
f <- function(x) x[1] * msft_for * x[1] + x[1] * cov_g[1, 2] * x[2] + x[1] * cov_g[1, 3] * x[3] + x[1] * cov_g[1, 4] * x[4] +
    x[2] * cov_g[2, 1] * x[1] + x[2] * aapl_for * x[2] + x[2] * cov_g[2, 3] * x[3] + x[2] * cov_g[2, 4] * x[4] +
    x[3] * cov_g[3, 1] * x[1] + x[3] * cov_g[3, 2] * x[2] + x[3] * ebay_for * x[3] + x[3] * cov_g[3, 4] * x[4] +
    x[4] * cov_g[4, 1] * x[1] + x[4] * cov_g[4, 2] * x[2] + x[4] * cov_g[4, 3] * x[3] + x[4] * googl_for * x[4]

theta <- c(0.48, 0.01, 0.015, 0.49)

ui <- rbind(
  c(1, 0, 0, 0),
  c(0, 1, 0, 0),
  c(0, 0, 1, 0),
  c(0, 0, 0, 1),
  c(-1, -1, -1, -1),
  c(1, 1, 1, 1),
  c(means_h)
)
ci <- c(
  0,
  0,
  0,
  0,
  -1,
  0.99,
  0.0002
) # 5.04% Annual Return Spread to Daily #

port_opt <- constrOptim(theta = theta, f = f, ui = ui, ci = ci, grad = NULL)

port_weights_g <- port_opt$par
port_var_g <- port_opt$value
names(port_weights_g) <- names(means_h)
final_g <- round(port_weights_g * 100, 2)

# Compare the Allocations #
allocation <- rbind(final_h, final_f, final_g)

stocks_compare <- cbind(
  to.weekly(AAPL)[, 4],
  to.weekly(MSFT)[, 4],
  to.weekly(EBAY)[, 4],
  to.weekly(GOOGL)[, 4]
)

stocks_compare$msft_r <- periodReturn(stocks_compare$MSFT.Close, period = "weekly")
stocks_compare$aapl_r <- periodReturn(stocks_compare$AAPL.Close, period = "weekly")
stocks_compare$ebay_r <- periodReturn(stocks_compare$EBAY.Close, period = "weekly")
stocks_compare$googl_r <- periodReturn(stocks_compare$GOOGL.Close, period = "weekly")

stocks_compare <- stocks_compare["2019-02-04/2019-02-08"]

returns_all <- c(
  stocks_compare[, 5:8] %*% final_h,
  stocks_compare[, 5:8] %*% final_f,
  stocks_compare[, 5:8] %*% final_g
)

var_all <- c(port_var_h, port_var_f, port_var_g)

results <- cbind(allocation, returns_all, var_all)

results
