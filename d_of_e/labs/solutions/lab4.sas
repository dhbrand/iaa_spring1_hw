* LAB 4 SOLUTION + SOME MORE STUFF*;

DATA RCBD; 
	INPUT worker plan rate; 
	Cards;
		1	1	82	
		1	2	59	
		1	3	62
		2	1	91
		2	2	75
		2	3	75
		3	1	98
		3	2	74
		3	3	81
		4	1	89
		4	2	69
		4	3	76
;

/*
* LAB 1 IN CLASS: GLM USING BLOCKS
*/
PROC GLM DATA = RCBD; 
	CLASS WORKER PLAN; /* A BLOCK IS TREATED EXCATLY LIKE A FACTOR*/ 
	MODEL RATE = WORKER PLAN; /*IT ENTERS THE MODEL THE SAME WAY TOO*/ 
	LSMEANS PLAN/CL ADJUST=TUKEY; 
	CONTRAST 'Plan 1 AND 3 vs. 2' PLAN 1 -1  0 
								  PLAN 1  0 -1; /* ARE 2 AND 3 JUST DIFFERENT THAN 1*/
	ESTIMATE 'Average Plan 1 and 2 vs. 3' PLAN 1 -0.5 -0.5; /*IF WE ASSUME 2 AND 3 ARE
															 THE SAME ARE THEY DIFFERENT
															 THAN 2;*/
	ESTIMATE 'EFFECT OF PLAN 2 VS 3'   PLAN 0  1 -1;  
RUN; 

* SET UP THE DATASET FOR
* THE DIFFERENCES AND PROC GLMPOWER 
* FIRST FIGURE OUT WHAT THE MEANS OF EACH GROUP ARE;
PROC GLM; 
	CLASS WORKER PLAN; 
	LSMEANS WORKER PLAN; 
	MODEL RATE = WORKER PLAN; 
	ESTIMATE 'WORKER 1 PLAN 1' INTERCEPT 1 WORKER 1 0 0 0 PLAN 1 0 0;
	ESTIMATE 'WORKER 1 PLAN 2' INTERCEPT 1 WORKER 1 0 0 0 PLAN 0 1 0;
	ESTIMATE 'WORKER 1 PLAN 3' INTERCEPT 1 WORKER 1 0 0 0 PLAN 0 0 1;
	ESTIMATE 'WORKER 2 PLAN 1' INTERCEPT 1 WORKER 0 1 0 0 PLAN 1 0 0;
	ESTIMATE 'WORKER 2 PLAN 2' INTERCEPT 1 WORKER 0 1 0 0 PLAN 0 1 0;
	ESTIMATE 'WORKER 2 PLAN 3' INTERCEPT 1 WORKER 0 1 0 0 PLAN 0 0 1;
	ESTIMATE 'WORKER 3 PLAN 1' INTERCEPT 1 WORKER 0 0 1 0 PLAN 1 0 0;
	ESTIMATE 'WORKER 3 PLAN 2' INTERCEPT 1 WORKER 0 0 1 0 PLAN 0 1 0;
	ESTIMATE 'WORKER 3 PLAN 3' INTERCEPT 1 WORKER 0 0 1 0 PLAN 0 0 1;
	ESTIMATE 'WORKER 4 PLAN 1' INTERCEPT 1 WORKER 0 0 0 1 PLAN 1 0 0;
	ESTIMATE 'WORKER 4 PLAN 2' INTERCEPT 1 WORKER 0 0 0 1 PLAN 0 1 0;
	ESTIMATE 'WORKER 4 PLAN 3' INTERCEPT 1 WORKER 0 0 0 1 PLAN 0 0 1;
RUN; 

* THESE ARE THE MODEL BASED ESTIMES WITH 
* NO INTERACTION TERM!
* THIS IS THE KEY TO USING PROC GLMPOWER
* YOU NEED TO SPECIFY THE MEAN FOR EACH GROUP; 
DATA PLAN1; 
	INPUT WORKER PLAN RATE; 
	CARDS; 
 1 1 80.0833333 
 1 2 59.3333333  
 1 3 63.5833333  
 2 1 92.7500000  
 2 2 72.0000000  
 2 3 76.2500000  
 3 1 96.7500000  
 3 2 76.0000000  
 3 3 80.2500000  
 4 1 90.4166667  
 4 2 69.6666667  
 4 3 73.9166667  
;
/*THIS IS BASED UPON THE RESULTS FROM THE STUDY*/ 
PROC GLMPOWER DATA=PLAN1; 
	CLASS WORKER PLAN;  /*NOTE THIS SYNTAX IS EXACTLY LIKE PROC GLM*/ 
	MODEL RATE = WORKER PLAN; 
	CONTRAST 'Plan 1 AND 3 vs. 2' PLAN 1 -1 0 
								  PLAN 1  0 -1; /* ARE 2 AND 3 JUST DIFFERENT THAN 1*/
	CONTRAST 'Average Plan 1 and 2 vs. 2' PLAN 1 -0.5 -0.5; /*IF WE ASSUME 2 AND 3 ARE
															 THE SAME ARE THEY DIFFERENT
															 THAN 2;*/
	CONTRAST 'EFFECT OF PLAN 2 VS 3'   PLAN 0  1 -1;  
	POWER  /*THIS IS THE ONLY PART YOU NEED TO WORRY ABOUT*/ 
		STDDEV = 2.33 /*Mean Square Error = MSE^0.5*/
		NTOTAL = 12  /*TOTAL OBSERVATIONS IN THE STUDY*/ 
		POWER  = .; 
RUN; 

/*THIS IS BASED UPON THE RESULTS FROM THE STUDY*/ 
/*BECAUSE NOTHING IS GOING ON IN THE FIRST MODEL LOOK WHAT HAPPENS
  IF I ADD AN INTERACTION*/ 
PROC GLMPOWER DATA=PLAN1; 
	CLASS WORKER PLAN;  /*NOTE THIS SYNTAX IS EXACTLY LIKE PROC GLM*/ 
	MODEL RATE = WORKER PLAN WORKER*PLAN; 
	POWER  /*THIS IS THE ONLY PART YOU NEED TO WORRY ABOUT*/ 
		STDDEV = 2.33 /*Mean Square Error = MSE^0.5*/
		NTOTAL = 144  /*TOTAL OBSERVATIONS IN THE STUDY 
						NOTE:MUST BE BIGGER THAN THE 
						ORIG SAMPLE SIZE WHY?*/ 
		POWER  = .; 
RUN; 
