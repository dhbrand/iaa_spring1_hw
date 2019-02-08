data portfolio;
input Computer Chemical Power Auto Electronics;
cards;
0.22816	-0.07205	0.0173	0.22266	0.08202
0.09134	0.02588	0.05646	0.01278	-0.03499
-0.01288	-0.04771	0.0228	0.00379	0.01662
-0.17196	0.06343	0	0.04101	-0.07496
0.16557	0.0367	0.0051	0.07576	-0.0081
-0.00789	0.01372	0.02244	0.06817	0.05446
-0.04909	0.0596	0.06583	-0.07143	-0.08607
0.22967	-0.02083	0.00812	-0.02564	0.01712
0.10117	0.00681	0.0236	0.12632	-0.0051
-0.1053	-0.05128	0.00865	0.16406	0.08367
-0.02767	0.0471	-0.02926	-0.05593	0.0489
0.00813	-0.01247	0.00893	0.01327	0.08498
0.05323	0.11894	-0.00885	0.15493	0.0979
0.05364	0.00197	-0.06917	-0.07317	-0.00382
-0.01818	-0.04479	-0.06473	-0.0864	-0.01546
-0.09556	0.04366	0.01384	-0.07952	0.03534
0.02459	0.08765	0.00259	0.03665	0.02402
-0.064	-0.0326	-0.01379	-0.03535	-0.02736
0.01393	0.05736	0.06993	0.01316	0.04604
0.10971	0.0868	0.02588	-0.0026	0.05501
-0.06464	0.05025	0.00645	-0.0599	-0.0035
0.01114	-0.0607	0.01603	0.08357	-0.03981
0.0161	-0.12925	0.04076	-0.00257	-0.03415
0.01188	0.06094	-0.06442	0.01856	0.00763
. . . . .
;

proc corr data=portfolio cov out=Corr;
	var Computer Chemical Power Auto Electronics;
run; 

data Cov;
	set Corr;
	where _TYPE_='COV';
run;

data Mean;
	set Corr;
	where _TYPE_='MEAN';
run;

proc optmodel;

	/* Declare Sets and Parameters */
	set <str> Assets1, Assets2, Assets3;
	num Covariance{Assets1,Assets2};
	num Mean{Assets1};

	/* Read in SAS Data Sets */
	read data Cov into Assets1=[_NAME_];
	read data Cov into Assets2=[_NAME_] {i in Assets1} <Covariance[i,_NAME_]=col(i)>;
	read data Mean into Assets3=[_NAME_] {i in Assets1} <Mean[i]=col(i)>;

	/* Declare Variables */
	var Proportion{Assets1}>=0 init 0;

	/* Declare Objective Function */
	min Risk = sum{i in Assets1}(sum{j in Assets1}Proportion[i]*Covariance[i,j]*Proportion[j]);

	/* Declare Constraints */
	con Return: 0.015 <= sum{i in Assets1}Proportion[i]*Mean[i];
	con Sum: 1 = sum{i in Assets1}Proportion[i];
	*con RisklessReturn: 0.015 <= sum{i in Assets1}Proportion[i]*Mean[i] + (1 - sum{i in Assets1}Proportion[i])*0.005;

	/* Call the Solver */
	solve;

	/* Print Solutions */
	print Covariance Mean;
	print Proportion 'Sum ='(sum{i in Assets1}Proportion[i]);

quit;


/**************************** PROGRAM BEGINS HERE ****************************
  Read in stocks_r.csv into stocks                                         */



%let stocks= AAPL MSFT INTC YHOO TGT WBA M KSS BBY PLKI PRLB;

/*Create monthly returns*/
  data _returns_;
  set stocks;
  month=month(date);
  year=year(date);
  run;
proc sort data= _returns_;
by year month;
run;

data _returns_;
 set _returns_ (drop= AMZN);
 run;

proc means data=_returns_ sum noprint;
  var &stocks;
  by year month;
  output out=monthly_returns(drop=_type_ _freq_)  sum=&stocks;
  run;

/*Get the expected value of monthly returns*/
  proc means data=monthly_returns mean noprint;
  var &stocks;
  output out=_expected_monthly_returns_(drop=_type_ _freq_) mean=;
  run; 
  proc transpose data=_expected_monthly_returns_ 
        out=_expected_monthly_returns_(rename=(Col1=monthly_return));
  run;

/*Get the covariance matrix of monthly returns*/
  proc corr data=monthly_returns cov out=_cov_monthly_returns_ noprint;
  var &stocks;
  run;
  data _cov_monthly_returns_(drop=_type_);
  set _cov_monthly_returns_(where=(_type_ = "COV"));
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
  set parameter_values = {0.26 to 0.4 by 0.020}; 

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
  con c2: exp_portf_return = Required_Portfolio_Return;

  /*READ INPUT DATA*/
  /*Read the expected monthly returns. The first column, _name_ holds the    */
  /*index of stock symbols we want to use; that's why we include it with [].*/ 
  read data work._expected_monthly_returns_ into Stock_Symbols=[_name_] expected_return_stock=monthly_return;
  /*Read the covariance matrix*/       
  read data work._cov_monthly_returns_ into [_name_] {j in Stock_Symbols} <Covariance[_name_,j]=col(j)>;

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
   create data obj_value_stddev_results from 
         [parameter_values] Portfolio_Stdev_Results Expected_Return_Results;

   /*Store the weights from all runs in a SAS dataset*/ 
   create data min_stddev_weight_results from 
         [_param_ _stock_]={parameter_values , stock_symbols} Weights_Results;
quit;

/*Efficient Frontier*/
proc sgplot data=Obj_value_stddev_results;
series x=Portfolio_Stdev_Results y=expected_return_results;
quit;
