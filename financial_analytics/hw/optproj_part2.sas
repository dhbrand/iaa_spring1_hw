/* Load Needed Data */
proc import datafile = 'stocks_top5.csv'
	out = stocks_top5 dbms = csv replace;
run;

/* Reset the Format to Avoid SGPLOT Warnings Later On */
data stocks_top5;
  set stocks_top5;
 *Date = input(Index,anydtdte32.);
  format index date7.;
run; 

/* Add 5 Observations for Forecasting at End of Series */
data stocks_top5(drop=i);
	set stocks_top5 end = eof;
	output;
	if eof then do i=1 to 5;
		if weekday(index) in(2,3,4,5) then index=index+1;
		else index=index+3;
    ibm_r=.;
	jnj_r=.;
	nke_r=.;
	pg_r=.;
	wmt_r=.;
    output;
  end;
run;

/* Estimate Different GARCH Models */
proc autoreg data=stocks_top5;
   ibm_garch_t:   model ibm_r =  / garch=(p=1, q=1, type=tGARCH) dist=t method=ml maxiter=250;
                            output out=ibm_garch_t ht=pred_var_ibm;
   jnj_qgarch:   model jnj_r =  / garch=(p=1, q=1, type=QGARCH) dist=t method=ml maxiter=250;
                            output out=jnj_qgarch ht=pred_var_jnj;
   nke_garch_t:  model nke_r = / garch=(p=1, q=1, type=tGARCH) dist=t method=ml maxiter=250;
                            output out=nke_garch_t ht=pred_var_nke;
   pg_garch_t:   model pg_r = / garch=(p=1, q=1, type=tGARCH) dist=t method=ml maxiter=250;
                            output out=pg_garch_t ht=pred_var_pg;
   wmt_qgarch:   model wmt_r =  / garch=(p=1, q=1, type=QGARCH) dist=t method=ml maxiter=250;
                            output out=wmt_qgarch ht=pred_var_wmt;
run;

/* Get New Forecasted Values for Variance */
data combined (keep=date pred_var_ibm pred_var_jnj pred_var_nke pred_var_pg pred_var_wmt);
	merge ibm_garch_t jnj_qgarch nke_garch_t pg_garch_t wmt_qgarch;
	if index <= '01FEB2019'd then delete;
run;

proc means data=combined median;
	var pred_var_ibm pred_var_jnj pred_var_nke pred_var_pg pred_var_wmt;
	output out=P_GARCH median=p_ibm p_jnj p_nke p_pg p_wmt;
run;

data _null_;
	set P_GARCH;
	call symput("ibm_pred", p_ibm);
	call symput("jnj_pred", p_jnj);
	call symput("nke_pred", p_nke);
	call symput("pg_pred", p_pg);
	call symput("wmt_pred", p_wmt);
run;

proc corr data=stocks_top5 cov  out=Corr;
	var ibm_r jnj_r nke_r pg_r wmt_r;
run;

proc means data=stocks_top5 median;
	var ibm_r jnj_r nke_r pg_r wmt_r;
	output out=Median median= /autoname;
run;

data Median;
  set Median;
  rename ibm_r_Median=ibm_r jnj_r_Median=jnj_r nke_r_Median=nke_r pg_r_Median=pg_r wmt_r_Median=wmt_r;
  _NAME_ = ' ';
run;

data Cov;
	set Corr;
	where _TYPE_='COV';
run;

data Cov;
	set Cov;
	if _NAME_="ibm_r" then ibm_r=&ibm_pred;
	if _NAME_="jnj_r" then jnj_r=&jnj_pred;
	if _NAME_="nke_r" then nke_r=&nke_pred;
	if _NAME_="pg_r" then pg_r=&pg_pred;
	if _NAME_="wmt_r" then wmt_r=&wmt_pred;
run;

proc optmodel;
  
  /* Declare Sets and Parameters */
  set <str> Assets1, Assets2, Assets3;
  num Covariance{Assets1,Assets2};
  num Median{Assets1};

  /* Read in SAS Data Sets */
  read data Cov into Assets1=[_NAME_];
  read data Cov into Assets2=[_NAME_] {i in Assets1}     
    <Covariance[I,_NAME_]=col(i)>;
  read data Med into Assets3=[_NAME_] {i in Assets1} <Median[i]=col(i)>;
  /* Declare Variables */
  var Proportion{Assets1} >= 0 init 0;

  /* Declare Objective Function */
  min Risk = sum{i in Assets1}
    (sum{j in Assets1}Proportion[i]*Covariance[i,j]*Proportion[j]);
  
  /* Declare Constraints */
  con Return: 0.0005 <= sum{i in Assets1}Proportion[i]*Median[i];
  con Sum: 1 = sum{i in Assets1}Proportion[i];

  /* Call the Solver */
  solve;

  /* Print Solutions */
  print Covariance Median;
  print Proportion;

  /* Output Results */
  create data Weight_G from [Assets1] Proportion;

quit;
