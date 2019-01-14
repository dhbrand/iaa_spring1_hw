*              Negative | Postitive |
* ------------------------------------------
* Control   |     a     |     b     |  na1
* ------------------------------------------
* Treatment |     c     |     d     |  na2
* ----------------------------------+-------
*           |     nb1   |    nb2    |  N
* N = nb1 + nb2         and    N = na1 + na2;
*
*Probability of positive given control b/na1 = b/(a+b)
*odds of negative   a/b = [a/(b+a)]/[b/(b+a)]
*Probability of negative given treatment c/na2 = c/(c+d)
*odds of negative   c/d = [c/(c+d)]/[c/(c+d)]
*Odds = p/(1-p);

*actual data from clas; 
proc format;
   value Trt  1='Treatment'
              0='Control';
   value Resp 1='Yes'
              0='No';
run;

data class; 
	input trt resp  count; 
cards; 
	0 0 8
	0 1 1
    1 0 3
	1 1 5
;
run; 

/*proc Freq needs the data in a sorted format*/ 
proc sort data=FatComp;
   by descending trt descending Response;
run;
*Analyze the data using proc freq; 
*Here you can see the following:
*1) The odds ratio is 13.333
*2) The table shows the reference conversion rate as 0.11111
*3) The table shows all of the proportions and the treatment
*   conversion rate is 0.625;
proc freq data = class; 
	format trt Trt. resp Resp.;  /*give it formats so you can 
								   understand your table*/ 
	table trt*resp/ chisq relrisk; /*define my 2x2 table*/ 
	weight count;   /* the number in each bin*/ 
	exact pchi or; /*exact test, chi-square and odds ratio*/ 
run; 

/*Using odds ratio:               13.33333
  and the reference proportion of: 0.111111
  also I am only using pchi, you can use others etc.
  if you want*/ 
proc power; 
	twosamplefreq test = pchi
	REFPROPORTION= 0.1111
	oddsratio= 13.3333
	alpha = 0.05
	power =. 
	groupns = (9 8); 
run; 

/*Using the proportion diff:       0.5139
  and the reference proportion of: 0.111111
  also I am only using pchi, you can use others.
  if you want*/ 
proc power; 
	twosamplefreq test = pchi
	REFPROPORTION= 0.1111
	proportiondiff= 0.5139 /*0.625-0.1111*/ 
	alpha = 0.05
	power =. 
	groupns = (9 8); 
run; 

/*Using the relative risk  
  Pr(trt=Conversion)/Pr(control=Conversion) = 1/0.1778 = 5.62
  Here the null relative risk is 1 (they are the same)
  and the reference proportion of 0.111111
  also I am only using pchi, you can use others.
  if you want*/ 
proc power; 
	twosamplefreq test = pchi
	REFPROPORTION= 0.1111
	nullrelativerisk=1
	relativerisk= 5.6242 
	alpha = 0.05
	power =. 
	groupns = (9 8); 
run; 
 
