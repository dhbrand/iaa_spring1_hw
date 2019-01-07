/*insurance data*/ 
data insure;
      input n claims car$ age;
      ln = log(n);
      datalines;
   500   42  small  1
   1200  37  medium 1
   100    1  large  1
   400  101  small  2
   500   73  medium 2
   300   14  large  2
   ;
   run;
/*initial cut at the data*/ 
proc genmod data=insure; 
		class car age/param=glm; *param=glm codes it like glm 
								 *so we can think of it in the same way;
		model claims = car age/dist   = poisson /*our data is count data we use 
												the poisson distribution*/
                          	   link   = log TYPE3 /*TYPE3 IS LIKE TYPE III SUMS OF SQUARES*/
                          	   offset = ln; /*THIS IS OVER A NUMBER OF CUSTOMERS*/ 
		contrast 'Large vs. small' car 1 0 -1;
	run; 
quit; 

