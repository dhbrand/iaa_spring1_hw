/* data for example 2
   in Lecture 1*/ 
data dubia_exp; 
	input dose age; 
	cards; 
	0 60
	0 90
	0 74
	0 82
	20 58
	20 74
    20 50
	20 65
	20 68
	40 40
	40 58
	40 25
	40 30
	40 42
; 

/* Using proc glm to answer questions
   for a 1-way anova*/ 
proc glm data = dubia_exp; 
	class dose;  /*treatment effects*/ 
	model age = dose; /*main model*/ 
	estimate '0ug -vs- 20ug' dose 1 -1  0;  *ANOVA BASED ESTIMATES; 
	estimate '0ug -vs- 40ug' dose 1 0  -1;
	estimate '0ug, 20ug -vs- 40ug' dose 0.5  0.5 -1; *must add to 0; 
	contrast '0ug -vs- 20ug' dose 1 -1  0; *ANOVA BASED TESTING;
	contrast '0ug -vs- 40ug' dose 1 0  -1; 
	contrast '0ug, 20ug -vs- 40ug' dose 0.5  0.5 -1; *must add to 0; 
run; 
quit; 

/* Using proc glm to answer questions
   for a 1-way anova*/ 
proc glm data = dubia_exp; 
	class dose;  /*treatment effects*/ 
	model age = dose; /*main model*/ 
	lsmeans dose/cl stderr adjust=tukey; /*get model based estimates
					 of the effect
					 -cl specifies we are requesting 
					  confidene limts
					 -tukey adjusts for multiple comparisons*/ 
run; 
quit; 
