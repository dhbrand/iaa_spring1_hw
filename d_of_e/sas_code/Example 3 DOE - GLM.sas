/*Example 3
*/

DATA LUNGCAPACITY;
	INPUT drug 
		  age
		  cap;
DATALINES;
1   50  10 
1   60  9
1   70  8
2   50  12
2   60  11
2   70  10
3   50  13
3   60  12
3   70  11
;
RUN;

PROC GLMPOWER DATA=LUNGCAPACITY; 
	CLASS DRUG;
	MODEL CAP = DRUG AGE; 
	CONTRAST 'DRUG 1 VS. DRUG 2' DRUG 1 -1 0; 
	CONTRAST 'DRUG 1 VS. DRUG 3' DRUG 1 0 -1; 
	CONTRAST 'DRUG 2 VS. DRUG 3' DRUG 0 1 -1; 
	POWER
		POWER=0.80
		NTOTAL=.
		STDDEV= 1;
		*standard deviation options
		*based on binomial proportion
		*approximating normality!;
	plot Y=POWER min=0 max=1; 
RUN; 
