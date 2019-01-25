/*Example 1. Car example */;
/*DOE-GLMPOWER Example 1*/ 

/*Unbalanced sample size*/
DATA car;
	INPUT engine
		  MPG;		  
	DATALINES;
1 30 
2 31	
3 33
;
RUN;

* ENGINE DATA LOOK AT THE CONTRAST -
*
;
PROC GLMPOWER DATA=CAR;
	CLASS engine;
	MODEL MPG = engine; 
	CONTRAST 'engine 1 VS. 2 contrast' engine 1 -1 0; 
	CONTRAST 'engine 1 VS. 3 contrast' engine 1  0 -1; 
	CONTRAST 'engine 2 VS. 3 contrast' engine 0  1 -1; 
	POWER
		ALPHA= 0.01667 /*FOR A BF ADJUSTMENT*/
		POWER=0.80
		NTOTAL=.
		STDDEV= 1 2; * ASSUME A SD OF 1 or 2 ; 
RUN;
