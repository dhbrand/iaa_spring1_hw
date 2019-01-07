/*----------------------------------*/
/*          Factor Models           */
/*                                  */
/*          Dr Aric LaBarr          */
/*----------------------------------*/


/* Load Needed Data */
proc import datafile = 'stocks_w.csv'
	out = stocks_w dbms = csv replace;
run;

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data stocks_w;
  set stocks_w;
  Date = input(Index,anydtdte32.);
  format Date date7.;
run; 

/* Plots of Returns */
proc sgplot data=stocks_w;
  title 'MSFT';
  series x = Date y = msft_r;
  yaxis label='Daily Returns of MSFT';
run;

proc sgplot data=stocks_w;
  title 'AAPL';
  series x = Date y = aapl_r;
  yaxis label='Daily Returns of AAPL';
run;

proc sgplot data=stocks_w;
  title 'GOOGL';
  series x = Date y = googl_r;
  yaxis label='Daily Returns of GOOGL';
run;

proc sgplot data=stocks_w;
  title 'EBAY';
  series x = Date y = ebay_r;
  yaxis label='Daily Returns of EBAY';
run;

/* Calculate DJIA Mean and Variance for CAPM */
proc means data=stocks_w mean var;
	var DJI_r;
	output out=DJIX var=Var mean=Mean;
run;

/* Calculate CAPM Regressions for Stocks */
proc reg data=stocks_w outest=Coef;
	MSFT: model MSFT_r = DJI_r;
	AAPL: model AAPL_r = DJI_r;
	GOOGL: model GOOGL_r = DJI_r;
	EBAY: model EBAY_r = DJI_r;
run;
quit;

/* Optimization of Assets - CAPM */
proc optmodel;
  
  /* Declare Sets and Parameters */
  set <str> Assets1;
  num Alpha{Assets1};
  num Beta{Assets1};
  num Sigma{Assets1};
  num MeanX;
  num VarX;

  /* Read in SAS Data Sets */
  read data Coef into Assets1=[_DEPVAR_] Alpha=col("Intercept");
  read data Coef into Assets1=[_DEPVAR_] Beta=col("DJI_r");
  read data Coef into Assets1=[_DEPVAR_] Sigma=col("_RMSE_");
  read data DJIX into MeanX=col("Mean");
  read data DJIX into VarX=col("Var");

  /* Declare Variables */
  var Proportion{Assets1} >= 0 init 0.2;

  /* Declare Objective Function */
  min Risk = sum{i in Assets1}Proportion[i]*Sigma[i]**2 
             + VarX*(sum{i in Assets1}Proportion[i]*Beta[i])**2;
  
  /* Declare Constraints */
  con Return: 0.002 <= sum{i in Assets1}Proportion[i]*Alpha[i] 
                        + MeanX*(sum{i in Assets1}Proportion[i]*Beta[i]);
  con Sum: 1 = sum{i in Assets1}Proportion[i];

  /* Call the Solver */
  solve;

  /* Print Solutions */
  print Alpha Beta Sigma MeanX VarX;
  print Proportion;* ‘Sum=’(sum{i in Assets1}Proportion[i]);

  /* Output Results */
  create data Weight_C from [Assets1] Proportion;

quit;

