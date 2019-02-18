/*-------------------------------*/
/*          Case Study           */
/*    Portfolio Optimization     */
/*                               */
/*        Dr Aric LaBarr         */
/*-------------------------------*/



/*==================================================================*/
/* Historical Approach */

/* Load Needed Data */
proc import datafile = 'stocks_h.csv'
	out = stocks_h dbms = csv replace;
run;

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data stocks_h;
  set stocks_h;
  Date = input(Index,anydtdte32.);
  format Date date7.;
run; 

/* Calculate the Correlation Between the Stocks */
proc corr data=stocks_h cov out=Corr;
	var msft_r aapl_r googl_r ebay_r;
run; 

data Cov;
	set Corr;
	where _TYPE_='COV';
run;

data Mean;
	set Corr;
	where _TYPE_='MEAN';
run;

/* Optimization of Assets - Historical Variance/Covariance */
proc optmodel;
  
  /* Declare Sets and Parameters */
  set <str> Assets1, Assets2, Assets3;
  num Covariance{Assets1,Assets2};
  num Mean{Assets1};

  /* Read in SAS Data Sets */
  read data Cov into Assets1=[_NAME_];
  read data Cov into Assets2=[_NAME_] {i in Assets1}     
    <Covariance[I,_NAME_]=col(i)>;
  read data Mean into Assets3=[_NAME_] {i in Assets1} <Mean[i]=col(i)>;
  /* Declare Variables */
  var Proportion{Assets1} >= 0 init 0;

  /* Declare Objective Function */
  min Risk = sum{i in Assets1}
    (sum{j in Assets1}Proportion[i]*Covariance[i,j]*Proportion[j]);
  
  /* Declare Constraints */
  con Return: 0.0002 <= sum{i in Assets1}Proportion[i]*Mean[i];
  con Sum: 1 = sum{i in Assets1}Proportion[i];

  /* Call the Solver */
  solve;

  /* Print Solutions */
  print Covariance Mean;
  print Proportion; *‘Sum=’(sum{i in Assets1}Proportion[i]);

  /* Output Results */
  create data Weight_H from [Assets1] Proportion;

quit;

/*==================================================================*/
/* CAPM Approach */

/* Load Needed Data */
proc import datafile = 'stocks_f.csv'
	out = stocks_f dbms = csv replace;
run;

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data stocks_f;
  set stocks_f;
  Date = input(Index,anydtdte32.);
  format Date date7.;
run; 

/* Calculate DJI Mean and Variance for CAPM */
proc means data=stocks_f mean var;
	var DJI_r;
	output out=DJIX var=Var mean=Mean;
run;

/* Calculate CAPM Regressions for Stocks for 2014-2016 */
proc reg data=stocks_f outest=Coef;
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
  var Proportion{Assets1} >= 0 init 0;

  /* Declare Objective Function */
  min Risk = sum{i in Assets1}Proportion[i]*Sigma[i]**2 
             + VarX*(sum{i in Assets1}Proportion[i]*Beta[i])**2;
  
  /* Declare Constraints */
  con Return: 0.00097 <= sum{i in Assets1}Proportion[i]*Alpha[i] 
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

/*==================================================================*/
/* GARCH Approach */

/* Load Needed Data */
proc import datafile = 'stocks_g.csv'
	out = stocks_g dbms = csv replace;
run;

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data stocks_g;
  set stocks_g;
  Date = input(Index,anydtdte32.);
  format Date date7.;
run; 

/* Add 5 Observations for Forecasting at End of Series */
data stocks_g(drop=i);
	set stocks_g end = eof;
	output;
	if eof then do i=1 to 5;
		if weekday(date) in(2,3,4,5) then date=date+1;
		else date=date+3;
    msft_p=.; msft_r=.;
	aapl_p=.; aapl_r=.;
	googl_p=.; googl_r=.;
	ebay_p=.; ebay_r=.;
    output;
  end;
run;

/* Estimate Different GARCH Models */
proc autoreg data=stocks_g;
   MSFT_qgarch_t:   model msft_r =  / garch=(p=1, q=1, type=QGARCH) dist=t method=ml maxiter=250;
                            output out=msft_qgarch_t ht=pred_var_msft;
   AAPL_qgarch_t:   model aapl_r =  / garch=(p=1, q=1, type=QGARCH) dist=t method=ml maxiter=250;
                            output out=aapl_qgarch_t ht=pred_var_aapl;
   GOOGL_qgarch_t:  model googl_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml maxiter=250;
                            output out=googl_qgarch_t ht=pred_var_googl;
   EBAY_qgarch_t:   model ebay_r = / garch=(p=1, q=1, type=QGARCH) dist=t method=ml maxiter=250;
                            output out=ebay_qgarch_t ht=pred_var_ebay;
run;

/* Get New Forecasted Values for Variance */
data combined (keep=date pred_var_msft pred_var_aapl pred_var_googl pred_var_ebay);
	merge msft_qgarch_t aapl_qgarch_t googl_qgarch_t ebay_qgarch_t;
	if date <= '01FEB2019'd then delete;
run;

proc means data=combined median;
	var pred_var_msft pred_var_aapl pred_var_googl pred_var_ebay;
	output out=P_GARCH median=p_MSFT p_AAPL p_GOOGL p_EBAY;
run;

data _null_;
	set P_GARCH;
	call symput("msft_pred", p_MSFT);
	call symput("aapl_pred", p_AAPL);
	call symput("googl_pred", p_GOOGL);
	call symput("ebay_pred", p_EBAY);
run;

proc corr data=stocks_g cov out=Corr;
	var msft_r aapl_r googl_r ebay_r;
run;

data Cov;
	set Corr;
	where _TYPE_='COV';
run;

data Mean;
	set Corr;
	where _TYPE_='MEAN';
run;

data Cov;
	set Cov;
	if _NAME_="msft_r" then msft_r=&msft_pred;
	if _NAME_="aapl_r" then aapl_r=&aapl_pred;
	if _NAME_="googl_r" then googl_r=&googl_pred;
	if _NAME_="ebay_r" then ebay_r=&ebay_pred;
run;

proc optmodel;
  
  /* Declare Sets and Parameters */
  set <str> Assets1, Assets2, Assets3;
  num Covariance{Assets1,Assets2};
  num Mean{Assets1};

  /* Read in SAS Data Sets */
  read data Cov into Assets1=[_NAME_];
  read data Cov into Assets2=[_NAME_] {i in Assets1}     
    <Covariance[I,_NAME_]=col(i)>;
  read data Mean into Assets3=[_NAME_] {i in Assets1} <Mean[i]=col(i)>;
  /* Declare Variables */
  var Proportion{Assets1} >= 0 init 0;

  /* Declare Objective Function */
  min Risk = sum{i in Assets1}
    (sum{j in Assets1}Proportion[i]*Covariance[i,j]*Proportion[j]);
  
  /* Declare Constraints */
  con Return: 0.0002 <= sum{i in Assets1}Proportion[i]*Mean[i];
  con Sum: 1 = sum{i in Assets1}Proportion[i];

  /* Call the Solver */
  solve;

  /* Print Solutions */
  print Covariance Mean;
  print Proportion;

  /* Output Results */
  create data Weight_G from [Assets1] Proportion;

quit;
