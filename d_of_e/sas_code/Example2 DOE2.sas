/*data marketing
  Example 2 data*/ 
data marketing; 
	input group spent @@; 
	cards ;
	1 100 1 110 1 92
	1 122 1 118 1 98
	1 130 1 110 2 115
    2 121 2 110 2 130
	2 142 2 108 2 112
	2 120 3 125 3 140
	3 153 3 142 3 130
    3 162 3 157 3 160
;


/*test the marketing data
  using an ANOVA based glm model*/ 
proc glm data = marketing; 
	class group; * types of groups; 
	model spent = group; *model; 
	lsmeans group/cl stderr adjust=tukey; *multiple mean comparisons; 
	contrast 'Nothing -vs- Mail' group 1 -1   0; *ANOVA BASED TESTING;
	contrast 'Nothing -vs- App ' group 1  0  -1; *For contrasts; 
	contrast 'Nothing, Mail -vs- App' group 0.5 0.5 -1;  
run;
quit; 
