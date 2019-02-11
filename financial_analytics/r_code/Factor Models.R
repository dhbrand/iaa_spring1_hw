#----------------------------------#
#           Factor Models          #
#                                  #
#           Dr Aric LaBarr         #
#----------------------------------#

# Needed Libraries for Analysis #
library(graphics)
library(quantmod)
library(ks)
library(scales)

# Load Stock Data & Calculate Returns#
tickers = c("AAPL", "MSFT","EBAY","GOOGL", "^DJI")

getSymbols(tickers)

stocks_w <- cbind(last(to.weekly(AAPL)[,4], "5 years"), 
                  last(to.weekly(MSFT)[,4], "5 years"), 
                  last(to.weekly(EBAY)[,4], "5 years"), 
                  last(to.weekly(GOOGL)[,4], "5 years"), 
                  last(to.weekly(DJI)[,4], "5 years"))

stocks_w$msft_r <- periodReturn(stocks_w$MSFT.Close, period = "weekly")
stocks_w$aapl_r <- periodReturn(stocks_w$AAPL.Close, period = "weekly")
stocks_w$ebay_r <- periodReturn(stocks_w$EBAY.Close, period = "weekly")
stocks_w$googl_r <- periodReturn(stocks_w$GOOGL.Close, period = "weekly")
stocks_w$dji_r <- periodReturn(stocks_w$DJI.Close, period = "weekly")

write.zoo(stocks_w, file = "financial_analytics/data/stocks_w.csv", sep=",")

# Plot Returns Data #
plot(stocks_w$msft_r, col="black", main="MSFT Stock Return (Logarithmic)", xlab="", ylab="Weekly Returns", lwd=2, type="l")

# Single Factor Models #
results_aapl <- lm(stocks_w$aapl_r ~ stocks_w$dji_r)
summary(results_aapl)
anova(results_aapl)

results <- lapply(6:9, function(x) lm(stocks_w[,x] ~ stocks_w[,10]))
names(results) <- c("MSFT", "AAPL", "EBAY", "GOOGL")

coefs <- sapply(results, coef, FUN.VALUE = matrix(nrow = 2, ncol = 4))

alphas <- coefs[1,]
betas <- coefs[2,]

sys_risk <- betas * sd(stocks_w$dji_r)

anova_res <- lapply(results, anova)

spec_risk <- NULL
for(i in names(results)){
  spec_risk[i] <- sqrt(anova_res[[i]][2,3])
}

CAPM_results <- rbind(alphas, betas, sys_risk, spec_risk)

# Optimize the Portfolio #
f <- function(x) x[1]*alphas[1] + x[2]*alphas[2] + x[3]*alphas[3] + x[4]*alphas[4] + 
                 var(stocks_w$dji_r)*(x[1]*betas[1] + x[2]*betas[2] + x[3]*betas[3] + x[4]*betas[4])^2

theta <- c(0.2,0.2,0.2,0.2)

ui <- rbind(c(1,0,0,0),
            c(0,1,0,0),
            c(0,0,1,0),
            c(0,0,0,1),
            c(-1,-1,-1,-1), 
            c(alphas + mean(stocks_w$dji_r)*betas))
ci <- c(0,
        0,
        0,
        0,
        -1,
        0.002)

port_opt <- constrOptim(theta = theta, f = f, ui = ui, ci = ci, grad = NULL)

port_weights <- port_opt$par
names(port_weights) <- names(results)
round(port_weights*100,2)

