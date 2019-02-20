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
	if index <= '08FEB2019'd then delete;
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

proc means data=stocks_top5 median noprint;
	var ibm_r jnj_r nke_r pg_r wmt_r;
	output out=Median(drop=_type_ _freq_) median=;
run;

/*data Median;
  set Median;
  rename ibm_r_Median=ibm_r jnj_r_Median=jnj_r nke_r_Median=nke_r pg_r_Median=pg_r wmt_r_Median=wmt_r;
  _NAME_ = ' ';
run;*/

proc transpose data=median out=_expected_monthly_returns(rename=(Col1=monthly_return));
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



/*Use OPTMODEL to setup and solve the minimum variance problem*/ 
  proc optmodel printlevel=0 FDIGITS=8;
  set <str> Stock_Symbols; 

  /*DECLARE OPTIMIZATION PARAMETERS*/  
  /*Expected return for each stock*/
  num expected_return_stock{Stock_Symbols};      
  /*Covariance matrix of stocks*/ 
  num Covariance{Stock_Symbols,Stock_Symbols};
  /*Required portfolio return: PARAMETER THAT WE WILL ANALYZE*/ 
  num Required_Portfolio_Return;   
  /*Range of parameter values*/ 
  set parameter_values = {0.0026 to 0.004 by 0.0002}; 

  /*OUTPUT*/
  /*Array to hold the value of the objective function*/
  num Portfolio_Stdev_Results{parameter_values};  
  /*Array to hold the value of the exp. return*/
  num Expected_Return_Results{parameter_values};  
  /*Array to hold the value of the weights*/
  num Weights_Results{parameter_values,Stock_Symbols};  

  /* DECLARE OPTIMIZATION VARIABLES AND THEIR CONSTRAINTS*/
  /*Short positions are not allowed*/
  var weights{Stock_Symbols}>=0;    

  /* Declare implied variables (Optional)*/
  impvar exp_portf_return = sum{i in Stock_Symbols} expected_return_stock[i] * weights[i];

  /* Declare constraints */
  con c1: sum{i in Stock_Symbols} weights[i] = 1;
  con c2: (exp_portf_return+1)**5 - 1 = Required_Portfolio_Return;
  con c3: exp_portf_return >= 0.0005;

  /*READ INPUT DATA*/
  /*Read the expected monthly returns. The first column, _name_ holds the    */
  /*index of stock symbols we want to use; that's why we include it with [].*/ 
  read data work._expected_monthly_returns into Stock_Symbols=[_name_] expected_return_stock=monthly_return;
  /*Read the covariance matrix*/       
  read data work.cov into [_name_] {j in Stock_Symbols} <Covariance[_name_,j]=col(j)>;

  /* DECLARE OBJECTIVE FUNCTION */ 
  min Portfolio_Stdev = 
     sum{i in Stock_Symbols, j in Stock_Symbols}Covariance[i,j] * weights[i] * weights[j];

  /*SOLVE THE PROBLEM FOR EACH PARAMETER VALUE*/
  for {r in parameter_values} do;
    /*Set the minimum portfolio return value to be used in each case*/
    Required_Portfolio_Return=r; 
    solve;
    /*Store the value of the objective function*/
    Portfolio_Stdev_Results[r]=Portfolio_Stdev; 
    /*Store the value of the expected returns*/ 
    Expected_Return_Results[r]=exp_portf_return;
    /*Store the weights*/
    for {i in Stock_Symbols} do;
      Weights_Results[r,i]=weights[i];
    end;
  end;

   /*Store the portfolio return and std.dev from all runs in a SAS dataset*/
   create data fin.obj_value_stddev_results from 
         [parameter_values] Portfolio_Stdev_Results Expected_Return_Results;

   /*Store the weights from all runs in a SAS dataset*/ 
   create data fin.min_stddev_weight_results from 
         [_param_ _stock_]={parameter_values , stock_symbols} Weights_Results;
quit;



/*Efficient Frontier*/
proc sgplot data=Obj_value_stddev_results;
series x=Portfolio_Stdev_Results y=expected_return_results;
quit;

/* calculating average proportion for each stock over the 5 day period*/
proc means data=min_stddev_weight_results mean;
class _stock_;
var weights_results;
output out=fin.proportions mean=;
run;
