/* Insulation example 1 for 
   Class 3 Notes*/ 
data insulation; 
	input month insulation cost @@;
	cards; 
1 1 74.44 2	1 89.96	3 1	82.00
1 2 68.75 2 2 73.47 3 2 71.23
1 3 71.34 2 3 83.62 3 3 79.88
1 4 65.47 2 4 72.33 3 4 70.87
;
/*
 Estimate the individual effects of the 
 given experimental design 
*/ 
proc glm data=insulation; 
	class month insulation; *we have one block and one factor;  
	model cost = month insulation; *cost is a linear model of the month and the 
								    type of insulation; 
	lsmeans insulation/cl adjust=TUKEY; *multiple effects adjustment TUKEY; 
	contrast 'Insulation 2 and 4 -vs- 1 and 3' insulation 0.5 -0.5 0.5 -0.5;
	estimate 'Insulation 2 and 4 -vs- 1 and 3' insulation 0.5 -0.5 0.5 -0.5;
run; 
quit; 


/* Cookie Chewiness for example 2
   class 3*/ 
data chew; 
	input chef kitchen flour chew @@; 
	cards; 
	1 1 1 1.620 1 1 1 1.342 1 2 1 2.669 1 2 1 2.687
	1 2 1 2.155 1 2 1 4.000 1 1 2 3.228 1 1 2 5.762
	1 2 2 6.219 1 2 2 8.207 1 1 3 6.615 1 1 3 8.245
	1 1 3 8.077 1 2 3 11.37 2 1 1 2.282 2 2 1 4.233
	2 2 1 4.664 2 2 1 3.002 2 2 1 4.506 2 2 1 6.385
	2 2 1 3.696 2 1 2 5.080 2 1 2 4.741 2 1 2 4.522
	2 2 2 4.647 2 2 2 4.999 2 2 2 5.939 2 1 3 8.240
	2 1 3 6.330 2 1 3 9.453 2 1 3 7.727 2 2 3 7.809
	2 2 3 8.942
;



proc glm data = chew; 
	*Three class variables; 
	class chef kitchen flour; 
	*Only main effects for now;
	model chew = flour chef kitchen; 
	lsmeans flour/cl adjust=bon;
	*above line adjusts using a Bonferroni adjustment; 
	run; 
quit;
