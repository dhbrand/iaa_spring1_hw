/*-------------------------------*/
/*      ARCH & GARCH Models      */
/*                               */
/*        Dr Aric LaBarr         */
/*-------------------------------*/


/*Data is in financial_analytics/data as a SAS Table */
/*            
proc import datafile = 'stocks.csv'
	out = stocks dbms = csv replace;
	datarow = 3;
run;

*Reset the Format to Avoid SGPLOT Warnings Later On;
data fin.Stocks;
  set fin.Stocks;
  Date = input(Index, anydtdte32.);
  format Date date7.;
run; 

*Add 10 Observations for Forecasting at End of Series/
data fin.stocks(drop=i);
	set fin.Stocks end = eof;
	output;
	if eof then do i=1 to 30;
		if weekday(Date) in(2,3,4,5) then Date=Date+1;
		else Date=Date+3;
		MSFT_Close=.;
		msft_r=.;
		output;
	end;
run;
 */


/* Plot the Price Data */
proc sgplot data=fin.Stocks;
  title "MSFT: Price";
  series x=Date y=MSFT_Close;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01JAN2007"d to "01JAN2019"d by year);
run;

/* Plot the Returns Data */
proc sgplot data=fin.Stocks;
  title "MSFT: Log Returns";
  series x=Date y=msft_r;
  keylegend / location=inside position=topright;
  xaxis VALUES= ("01JAN2007"d to "01JAN2019"d by year);
run;

/* Fit Kernel Density-estimation on Log Returns*/
proc sgplot data=fin.Stocks;
  title "MSFT: Log Returns Kernel Density";
  density msft_r / type=kernel;
  keylegend / location=inside position=topright;
run;

/* Test for GARCH Effects and Normality */
proc autoreg data=fin.Stocks all plots(unpack);
   model msft_r =/ archtest normal;
run;

/* Estimate Different GARCH Models */
ods output FitSummary=fitsum_all_garch_models;
proc autoreg data=fin.Stocks OUTEST=param_estimates;
   garch_n:   model msft_r = / noint garch=(p=1, q=1) method=ml; 
                            output out=garch_n ht=predicted_var;
   garch_t:   model msft_r =  / noint garch=(p=1, q=1) dist=t method=ml; 
                            output out=garch_t ht=predicted_var;
   egarch:    model msft_r = / noint garch=(p=1, q=1 ,type=exp ) method=ml;  
                            output out=egarch ht=predicted_var;
   qgarch_t:  model msft_r = / noint garch=(p=1, q=1, type=QGARCH) dist=t method=ml;
                            output out=qgarch_t ht=predicted_var;
   qgarch:    model msft_r = / noint garch=(p=1, q=1, type=QGARCH) method=ml;
                            output out=qgarch ht=predicted_var;
   garch_m:   model msft_r = / noint garch=(p=1, q=1, mean=linear) method=ml;
   							output out=garch_m ht=predicted_var;
   ewma:      model msft_r = / noint garch=(p=1, q=1, type=integ,noint) method=ml;
                            output out=ewma ht=predicted_var;
run;

/* Prepare Data for Plotting the Results */
data all_results;
  set garch_n(in=a) garch_t(in=b) egarch(in=c) qgarch_t(in=d) garch_m(in=e) ewma(in=f);
  format model $20.;
  if a then model="GARCH: Normal";
  if b then model="GARCH: T dist";
  else if c then model="Exp. GARCH";
  else if d then model="Quad. GARCH: T dist";
  else if e then model="GARCH Mean";
  else if f then model="EWMA";
run;

proc sort data=all_results;
  by model;
run;

/* Plot the Different Model Forecasts */
title;
proc gplot data=all_results /*(where=(Date ge '01JAN2013'd))*/;
  plot (predicted_var)*Date = model/ legend=legend1;
  plot msft_r*Date / legend=legend1;
  symbol1 i=join c=blue      w=2 v=none;
  symbol2 i=join c=green     w=2 v=none;
  symbol3 i=join c=red       w=2 v=none;
  symbol4 i=join c=magenta   w=2 v=none;
  symbol5 i=join c=black     w=2 v=none;
  symbol6 i=none c=purple    w=1 v=dot;
run;
quit;

/* Extract AIC, SBC and LIK measures */
data sbc_aic_lik;
   set fitsum_all_garch_models;
   keep Model SBC AIC Likelihood;
   if upcase(Label1)="SBC" then do; SBC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="SBC" then do; SBC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="AIC" then do; AIC=input(cValue1,BEST12.4); end;
   if upcase(Label2)="AIC" then do; AIC=input(cValue2,BEST12.4); end;
   if upcase(Label1)="LOG LIKELIHOOD" then do; Likelihood=input(cValue1,BEST12.4); end;
   if upcase(Label2)="LOG LIKELIHOOD" then do; Likelihood=input(cValue2,BEST12.4); end;
   if not ((SBC=.) and (Likelihood=.)) then output;
run;
