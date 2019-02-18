#-----------------------------------------------------#
#         Financial Analytics/Optimization HW #2      #
#-----------------------------------------------------#

# load CSV data file
library(stringr)
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
library(dplyr)

DJIA = c("MMM","AXP","AAPL","BA","CAT","CVX","CSCO","KO","DWDP","XOM","GS","HD","IBM","INTC","JNJ",
         "JPM","MCD","MRK","MSFT","NKE","PFE","PG","TRV","UNH","UTX","VZ","V","WMT","WBA","DIS")


# getSymbols(DJIA)
# 
# stocks <- cbind(MMM[,4],AXP[,4],AAPL[,4],BA[,4],CAT[,4],CVX[,4],CSCO[,4],KO[,4],DWDP[,4],XOM[,4],GS[,4],HD[,4],
#       IBM[,4],INTC[,4],JNJ[,4],JPM[,4],MCD[,4],MRK[,4],MSFT[,4],NKE[,4],PFE[,4],PG[,4],TRV[,4],UNH[,4],UTX[,4],VZ[,4],V[,4],WMT[,4],WBA[,4],DIS[,4])
# 
# paste_names <- paste(DJIA,".returns",sep = '')
# 
# #Create Rolling returns for each stock
# #Cbind the stock DF with the returns DF
# 
# iterations = 3049
# variables = 30
# 
# output <- matrix(ncol=variables, nrow=iterations)
# 
# for(i in 1:variables){
#   output[,i] <- ROC(stocks[,i])
# }
# 
# stocks <- cbind(stocks,output)
# 
# stocks <- stocks["2017-02/2019-02-08"]
# 
# paste_names
# 
# colnames(stocks)[31:60] <- c(paste_names)

stocks <- readr::read_csv("financial_analytics/hw/Stocks.csv")
stocks <- stocks[,2:61]

# Part 1 #

# Rank stocks by ARCH test significance
ARCH_tests = list()
for (i in 1:30){
  ARCH_tests[DJIA[i]] = arch.test(arima(stocks[,i+30], order = c(0,0,0)), output = TRUE)[,4]
}
warnings()
tests <- data.frame(unlist(ARCH_tests), DJIA)
tests <- arrange(tests,desc(unlist.ARCH_tests.))
## Top 5: WMT, JNJ, PG, IBM, NKE
top5 = c("IBM.Close","JNJ.Close","NKE.Close","PG.Close","WMT.Close","ibm_r","jnj_r","nke_r","pg_r","wmt_r")

# Create GARCH models and get parameters and AIC for each stock

info = data.frame()

for (i in top5[6:10]){
  
  temp <- data.frame()
  
  j <- 1
  # GARCH-Normal
  GARCH.N <- garchFit(formula= ~ garch(1,1), data=stocks[,i],
                      cond.dist="norm", include.mean = FALSE)
  temp[i,"model"] <- "GARCH-Normal"
  temp[i,"alpha"] <- GARCH.N@fit$par["alpha1"]
  temp[i,"beta"]  <- GARCH.N@fit$par["beta1"]
  temp[i,"AIC"]   <- GARCH.N@fit$ics["AIC"]
  
  j <- 2
  # GARCH-t
  GARCH.t <- garchFit(formula= ~ garch(1,1), data=stocks[,i], 
                      cond.dist="std", include.mean = FALSE)
  temp[j,"model"] <- "GARCH-t"
  temp[j,"alpha"] <- GARCH.t@fit$par["alpha1"]
  temp[j,"beta"]  <- GARCH.t@fit$par["beta1"]
  temp[j,"AIC"]   <- GARCH.t@fit$ics["AIC"]
  
  j <- 3
  # QGARCH-Normal
  Skew.GARCH.N <- garchFit(formula= ~ garch(1,1), data=stocks[,i], 
                           cond.dist="snorm",include.mean = FALSE)
  temp[j,"model"] <- "QGARCH-Normal"
  temp[j,"alpha"] <- Skew.GARCH.N@fit$par["alpha1"]
  temp[j,"beta"]  <- Skew.GARCH.N@fit$par["beta1"]
  temp[j,"AIC"]   <- Skew.GARCH.N@fit$ics["AIC"]
  
  j <- 4
  # QGARCH-t
  Skew.GARCH.t <- garchFit(formula= ~ garch(1,1), data=stocks[,i], 
                           cond.dist="sstd", include.mean = FALSE)
  temp[j,"model"] <- "QGARCH-t"
  temp[j,"alpha"] <- Skew.GARCH.t@fit$par["alpha1"]
  temp[j,"beta"]  <- Skew.GARCH.t@fit$par["beta1"]
  temp[j,"AIC"]   <- Skew.GARCH.t@fit$ics["AIC"]
  
  info <- bind_rows(info, temp)
}

# best models
best_GARCH_models <- info[c(2,8,10,14,20),]
top <- c("IBM", "JNJ", "NKE","PG", "WMT")
best_GARCH_models["stock"] <- top

# Next 5 days of volatility for using top model for each stock
# IBM best model is GARCH-t
ibm_mod <- garchFit(formula= ~ garch(1,1), data=stocks[,'ibm_r'], 
                    cond.dist="std", include.mean = FALSE)
ibm_for <- predict(ibm_mod, n.ahead=5)$standardDeviation

# JNJ best model is QGARCH-t
jnj_mod <- garchFit(formula= ~ garch(1,1), data=stocks[,'jnj_r'], 
                    cond.dist="sstd", include.mean = FALSE)
jnj_for <- predict(jnj_mod, n.ahead=5)$standardDeviation

# NKE best model is GARCH-t
nke_mod <- garchFit(formula= ~ garch(1,1), data=stocks[,'nke_r'], 
                    cond.dist="std", include.mean = FALSE)
nke_for <- predict(nke_mod, n.ahead=5)$standardDeviation

# PG best model is GARCH-t
pg_mod <- garchFit(formula= ~ garch(1,1), data=stocks[,'pg_r'], 
                   cond.dist="std", include.mean = FALSE)
pg_for <- predict(pg_mod, n.ahead=5)$standardDeviation

# WMT best model is QGARCH-t
wmt_mod <- garchFit(formula= ~ garch(1,1), data=stocks[,'wmt_r'], 
                    cond.dist="sstd", include.mean = FALSE)
wmt_for <- predict(wmt_mod, n.ahead=5)$standardDeviation

# rank by alpha (most susceptible to market shock)
rank_alpha <- arrange(best_GARCH_models, desc(alpha))
## from most to least susceptible: NKE, WMT, JNJ, IBM, PG

# rank by beta (longest lasting shock effects)
rank_beta <- arrange(best_GARCH_models, desc(beta))
## from longest to shortest effect: PG, IBM, JNJ, NKE, WMT

# Part 2 ####
# historical median return for each of 5 top stocks
hist_med_ret <- purrr::map_dbl(stocks[,top5[6:10]], median) %>% 
  cbind(top5[6:10], .)

readr::write_csv(stocks[,c('Index',top5)], path = "financial_analytics/data/stocks_top5.csv")


