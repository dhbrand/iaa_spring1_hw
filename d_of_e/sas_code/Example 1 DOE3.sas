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

/*
 Estimate the individual effects of the 
 given experimental design 
*/ 
proc glm data=insulation; 
	class  insulation; *we have one block and one factor;  
	model cost =  insulation; *cost is a linear model of the month and the 
								    type of insulation; 
	lsmeans insulation/cl adjust=TUKEY; *multiple effects adjustment TUKEY; 
	contrast 'Insulation 2 and 4 -vs- 1 and 3' insulation 0.5 -0.5 0.5 -0.5;
	estimate 'Insulation 2 and 4 -vs- 1 and 3' insulation 0.5 -0.5 0.5 -0.5;
run; 
quit; 
