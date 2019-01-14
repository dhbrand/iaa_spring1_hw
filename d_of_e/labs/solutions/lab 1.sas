/*lab 1*/  
data dubia_exp; 
	input dose age; 
	cards; 
	0 60
	0 90
	0 74
	0 82
	40 40
	40 58
    40 25
	40 30
	40 42
; 

/*t-test with the data 
  use the mean difference and the 
  pooled variance*/ 
proc ttest data = dubia_exp; 
	class dose; 
	var age; 
run; 
quit; 


/*what was the (approximate) power to detect a difference between
  the two groups if alpha = 0.01. Note: our sample size per group is not even*/ 
proc power;
      twosamplemeans
	  test=diff /* standard test for differences*/ 
	  alpha =  0.01 /*set the alpha = 0.01*/ 
	  meandiff = 37.5000 /*observed mean difference*/ 
	  stddev = 12.75 /*standard deviation of the pooled groups*/ 
	  ntotal = 9 
	  power = .; 
run; 

/*what was the (approximate) power to detect a difference between
  the two groups. Note: our sample size per group is not even*/ 
proc power;
      twosamplemeans
	  test=diff_satt /*Satterwaite approx*/ 
	  alpha = 0.05 0.01
	  meandiff = 37.5000
	  stddev = 12.75
	  ntotal = 9 
	  power = .; 
run; 
