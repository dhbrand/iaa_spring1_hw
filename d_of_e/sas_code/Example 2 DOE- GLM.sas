/*Example 2 
 *GLMPOWER */ 

/*Unbalanced sample size
  with 2 factors*/
/*THIS DATASET ASSUMES THAT THERE IS NO INTERACTION
  BETWEEN FACTORS*/ 
DATA CREDIT;
	INPUT intro $1-4
		  goto $6-9
		  responserate
		  size; /*unbalanced sample sizes*/
	DATALINES;
LOW  LOW 	0.0135	10 
LOW  HIGH	0.0125	1	
HIGH LOW	0.0110	1	
HIGH HIGH	0.010	10
;
RUN;

/* ASSUME THAT THERE IS NO INTERACTION!*/
PROC GLMPOWER DATA=CREDIT;
	CLASS intro goto;
	MODEL responserate= intro goto;
	WEIGHT size;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV= %SYSFUNC(SQRT(0.01*(1-0.01))) %SYSFUNC(SQRT(0.0135*(1-0.0135)));
										  *standard deviation options
										   *based on binomial proportion
										   *approximating normality!;
RUN;

/*Unbalanced sample size
  with 2 factors*/
/*THIS DATASET ASSUMES THAT THERE IS AN INTERACTION
  BETWEEN FACTORS*/ 
DATA CREDIT2;
	INPUT intro $1-4
		  goto $6-9
		  responserate
		  size; /*unbalanced sample sizes*/
	DATALINES;
LOW  LOW 	0.0135	10 
LOW  HIGH	0.0125	1	
HIGH LOW	0.0110	1	
HIGH HIGH	0.007	10
;
RUN;

/* ASSUME THAT THERE IS NO INTERACTION!*/
PROC GLMPOWER DATA=CREDIT2;
	CLASS intro goto;
	MODEL responserate= intro goto intro*goto;
	WEIGHT size;
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV= %SYSFUNC(SQRT(0.007*(1-0.007))) 
				%SYSFUNC(SQRT(0.0135*(1-0.0135)));
			  *standard deviation options
			  *based on binomial proportion
			  *approximating normality!;
RUN;
