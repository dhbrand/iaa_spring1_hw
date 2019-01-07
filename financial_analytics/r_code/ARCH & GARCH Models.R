#----------------------------------#
#         ARCH & GARCH Models      #
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

# Load Stock Data & Calculate Returns#
tickers = c("AAPL", "MSFT")

getSymbols(tickers)

stocks <- cbind(AAPL[,4] ,MSFT[,4])

stocks$msft_r <- ROC(stocks$MSFT.Close)
stocks$aapl_r <- ROC(stocks$AAPL.Close)

write.zoo(stocks, file = "C:/Users/adlabarr/Documents/Courses/IAA/Simulation and Risk/Data/stocks.csv", sep=",")

# Plot Price Data #
plot(stocks$MSFT.Close, col="black", main="MSFT Stock Price", xlab="", ylab="Price", lwd=2, type="l")

# Plot Returns Data #
plot(stocks$msft_r, col="black", main="MSFT Stock Return (Logarithmic)", xlab="", ylab="Daily Returns", lwd=2, type="l")

hist(stocks$msft_r, breaks=50, main='MSFT Return Distribution', xlab='Daily Returns')

# Test for GARCH Effects and Normality - Functions cannot handle NA values #
arch.test(arima(stocks$msft_r[-1], order = c(0,0,0)), output = TRUE)

jb.test(stocks$msft_r[-1]) 

# Estimate Different GARCH Models #
GARCH.N <- garchFit(formula= ~ garch(1,1), data=stocks$msft_r[-1],
                    cond.dist="norm", include.mean = FALSE)
summary(GARCH.N)

GARCH.t <- garchFit(formula= ~ garch(1,1), data=stocks$msft_r[-1], 
                    cond.dist="std", include.mean = FALSE)
summary(GARCH.t)

EGARCH <- ugarchfit(data = stocks$msft_r[-1], 
                    spec = ugarchspec(variance.model = list(model = "eGARCH", 
                                                            garchOrder = c(1,1))))
EGARCH

Skew.GARCH.N <- garchFit(formula= ~ garch(1,1), data=stocks$msft_r[-1], 
                         cond.dist="snorm",include.mean = FALSE)
summary(Skew.GARCH.N)

Skew.GARCH.t <- garchFit(formula= ~ garch(1,1), data=stocks$msft_r[-1], 
                         cond.dist="sstd", include.mean = FALSE)
summary(Skew.GARCH.t)

GARCH.M <- ugarchfit(data = stocks$msft_r[-1], 
                     spec = ugarchspec(variance.model=list(model="sGARCH", 
                                                           garchOrder=c(1,1)), 
                                       mean.model=list(armaOrder=c(0,0))))
GARCH.M

EWMA <- ugarchfit(data = stocks$msft_r[-1], 
                  spec = ugarchspec(variance.model=list(model="iGARCH", 
                                                        garchOrder=c(1,1), 
                                                        variance.targeting=0), 
                                    mean.model=list(armaOrder=c(0,0))))
EWMA
