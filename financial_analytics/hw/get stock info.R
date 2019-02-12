library(quantmod)

# Load Stock Data & Calculate Returns#
DJIA = c("MMM","AXP","AAPL","BA","CAT","CVX","CSCO","KO","DWDP","XOM","GS","HD","IBM","INTC","JNJ",
         "JPM","MCD","MRK","MSFT","NKE","PFE","PG","TRV","UNH","UTX","VZ","V","WMT","WBA","DIS")

getSymbols(DJIA)

stocks <- cbind(MMM[,4],AXP[,4],AAPL[,4],BA[,4],CAT[,4],CVX[,4],CSCO[,4],KO[,4],DWDP[,4],XOM[,4],GS[,4],HD[,4],IBM[,4],INTC[,4],JNJ[,4],
                JPM[,4],MCD[,4],MRK[,4],MSFT[,4],NKE[,4],PFE[,4],PG[,4],TRV[,4],UNH[,4],UTX[,4],VZ[,4],V[,4],WMT[,4],WBA[,4],DIS[,4])

stocks$mmm_r <- ROC(stocks$MMM.Close)
stocks$axp_r <- ROC(stocks$AXP.Close)
stocks$aapl_r <- ROC(stocks$AAPL.Close)
stocks$ba_r <- ROC(stocks$BA.Close)
stocks$cat_r <- ROC(stocks$CAT.Close)
stocks$cvx_r <- ROC(stocks$CVX.Close)
stocks$csco_r <- ROC(stocks$CSCO.Close)
stocks$ko_r <- ROC(stocks$KO.Close)
stocks$dwdp_r <- ROC(stocks$DWDP.Close)
stocks$xom_r <- ROC(stocks$XOM.Close)
stocks$gs_r <- ROC(stocks$GS.Close)
stocks$hd_r <- ROC(stocks$HD.Close)
stocks$ibm_r <- ROC(stocks$IBM.Close)
stocks$intc_r <- ROC(stocks$INTC.Close)
stocks$jnj_r <- ROC(stocks$JNJ.Close)
stocks$jpm_r <- ROC(stocks$JPM.Close)
stocks$mcd_r <- ROC(stocks$MCD.Close)
stocks$mrk_r <- ROC(stocks$MRK.Close)
stocks$msft_r <- ROC(stocks$MSFT.Close)
stocks$nke_r <- ROC(stocks$NKE.Close)
stocks$pfe_r <- ROC(stocks$PFE.Close)
stocks$pg_r <- ROC(stocks$PG.Close)
stocks$trv_r <- ROC(stocks$TRV.Close)
stocks$unh_r <- ROC(stocks$UNH.Close)
stocks$utx_r <- ROC(stocks$UTX.Close)
stocks$vz_r <- ROC(stocks$VZ.Close)
stocks$v_r <- ROC(stocks$V.Close)
stocks$wmt_r <- ROC(stocks$WMT.Close)
stocks$wba_r <- ROC(stocks$WBA.Close)
stocks$dis_r <- ROC(stocks$DIS.Close)

# Filter to desired time period
stocks <- stocks["2017-02/2019-02-08"]

write.zoo(stocks, file = "C:/Users/Bill/Documents/GitHub/og_sp1_hw/financial_analytics/hw/Stocks.csv", sep=",")
