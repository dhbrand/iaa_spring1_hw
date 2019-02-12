#-----------------------------------------------------#
#         Financial Analytics/Optimization HW #2      #
#-----------------------------------------------------#

# load CSV data file

library(graphics)
library(TTR)
library(ks)
library(scales)
library(forecast)
library(aTSA)
library(ccgarch)
library(fGarch)
library(rugarch)
library(dplyr)

DJIA = c("MMM","AXP","AAPL","BA","CAT","CVX","CSCO","KO","DWDP","XOM","GS","HD","IBM","INTC","JNJ",
         "JPM","MCD","MRK","MSFT","NKE","PFE","PG","TRV","UNH","UTX","VZ","V","WMT","WBA","DIS")

# Part 1 #

# Rank stocks by ARCH test significance
ARCH_tests = list()
for (i in 1:30){
  ARCH_tests[DJIA[i]] = sum(arch.test(arima(stocks[,(i+30)], order = c(0,0,0)), output = TRUE)[,5])
}
tests <- data.frame(unlist(ARCH_tests), DJIA)
tests <- arrange(tests,unlist.ARCH_tests.)
## Top 5: IBM, JNJ, NKE, PG, WMT
top5 = c("IBM.Close","JNJ.Close","NKE.Close","PG.Close","WMT.Close","ibm_r","jnj_r","nke_r","pg_r","wmt_r")
stocks <- data.frame(stocks)
stocks <- stocks[,top5]

# Create GARCH models and get parameters and AIC for each stock

info = data.frame()
top = c("IBM", "JNJ", "NKE", "PG", "WMT")
for (i in 1:5){
  
  temp <- data.frame()
  
  j <- 1
  # GARCH-Normal
  GARCH.N <- garchFit(formula= ~ garch(1,1), data=stocks[,i+5],
                      cond.dist="norm", include.mean = FALSE)
  temp[j,"model"] <- "GARCH-Normal"
  temp[j,"alpha"] <- GARCH.N@fit$par["alpha1"]
  temp[j,"beta"]  <- GARCH.N@fit$par["beta1"]
  temp[j,"AIC"]   <- GARCH.N@fit$ics["AIC"]
  
  j <- 2
  # GARCH-t
  GARCH.t <- garchFit(formula= ~ garch(1,1), data=stocks[,i+5], 
                      cond.dist="std", include.mean = FALSE)
  temp[j,"model"] <- "GARCH-t"
  temp[j,"alpha"] <- GARCH.t@fit$par["alpha1"]
  temp[j,"beta"]  <- GARCH.t@fit$par["beta1"]
  temp[j,"AIC"]   <- GARCH.t@fit$ics["AIC"]
  
  j <- 3
  # QGARCH-Normal
  Skew.GARCH.N <- garchFit(formula= ~ garch(1,1), data=stocks[,i+5], 
                           cond.dist="snorm",include.mean = FALSE)
  temp[j,"model"] <- "QGARCH-Normal"
  temp[j,"alpha"] <- Skew.GARCH.N@fit$par["alpha1"]
  temp[j,"beta"]  <- Skew.GARCH.N@fit$par["beta1"]
  temp[j,"AIC"]   <- Skew.GARCH.N@fit$ics["AIC"]
  
  j <- 4
  # QGARCH-t
  Skew.GARCH.t <- garchFit(formula= ~ garch(1,1), data=stocks[,i+5], 
                           cond.dist="sstd", include.mean = FALSE)
  temp[j,"model"] <- "QGARCH-t"
  temp[j,"alpha"] <- Skew.GARCH.t@fit$par["alpha1"]
  temp[j,"beta"]  <- Skew.GARCH.t@fit$par["beta1"]
  temp[j,"AIC"]   <- Skew.GARCH.t@fit$ics["AIC"]
  
  info <- bind_rows(info, temp)
}

# best models
info <- info[c(2,8,10,14,20),]
info["stock"] <- top

# rank by alpha (most susceptible to market shock)
info <- arrange(info, desc(alpha))
## from most to least susceptible: NKE, WMT, JNJ, IBM, PG

# rank by beta (longest lasting shock effects)
info <- arrange(info, desc(beta))
## from longest to shortest effect: PG, IBM, JNJ, NKE, WMT
