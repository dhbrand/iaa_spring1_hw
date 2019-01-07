/*example 2 ingots data*/ 
data ingots;
   input Heat Soak r n @@;
   datalines;
7 1.0 0 10  14 1.0 0 31  27 1.0 1 56  51 1.0 3 13
7 1.7 0 17  14 1.7 0 43  27 1.7 4 44  51 1.7 0  1
7 2.2 0  7  14 2.2 2 33  27 2.2 0 21  51 2.2 0  1
7 2.8 0 12  14 2.8 0 31  27 2.8 1 22  51 4.0 0  1
7 4.0 0  9  14 4.0 0 19  27 4.0 1 16
;

/*binomial distribution
  logit analysis saturated model*/ 
proc genmod data=ingots; 
	class heat soak;
	/*r observations total of n ingots*/  
	model r/n = heat soak/ dist=bin   /*binomial distribution*/
						   TYPE3      /*type 3 analysis of deviance*/
						   link=logit; /*logit link*/;
	contrast 'Background vs 27 heat' heat 0 0 1 -1; 
	contrast 'Backtroung vs 14 heat' heat 0 1 0 -1; 
	/*These are not the Wald tests above, 
	  they will not have the same P-value*/
run; 

/*Look at as a linear term*/ 
proc genmod data=ingots; 
	*class heat soak;
	/*r observations total of n ingots*/  
	model r/n = heat / dist=bin   /*binomial distribution*/
						   TYPE3      /*type 3 analysis of deviance*/
						   link=logit; /*logit link*/;
run; 
