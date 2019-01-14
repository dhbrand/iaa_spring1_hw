/*build the dataset*/ 
data depression; 
input grp dep @@; 
log_dep = log(dep); 
cards ; 
1 15  1 29 1 14 1 28 1 26 1 16 1 22 1 34 1 19 1 9 1 20 1 9
2 28  2 35 2 26 2 18 2 18 2 23 2 24 2 29 2 23 2 5 2 18 2 17
3 6   3  3 3  7 3  5 3 11 3  4 3  5 3  7 3  6 3 1 3 2 3  6
;
run; 

/*GLM for the first part*/ 
proc glm data = depression alpha=0.05; /*set the default alpha level 
										 explicitly for the test*/  
	class grp; 
	model dep = grp; 
	estimate 'Mean of group 1 and group 2' intercept 1 grp 0.5 0.5 0; /*must have the intercept*/ 
	lsmeans grp/ cl adjust=TUKEY; /*tukey's multiplicity adjustment*/ 
	lsmeans grp/ cl adjust=BON;    /*Bonferonni adjustment*/ 
run; quit; 


/*GLM for the first part*/ 
proc glm data = depression alpha=0.05; /*set the default alpha level 
										 explicitly for the test*/  
	class grp; 
	model log_dep = grp; 
	estimate 'Mean of group 1 and group 2' intercept 1 grp 0.5 0.5 0; /*must have the intercept*/ 
	lsmeans grp/ cl adjust=TUKEY; /*tukey's multiplicity adjustment*/ 
	lsmeans grp/ cl adjust=BON;    /*Bonferonni adjustment*/ 
run; quit; 
