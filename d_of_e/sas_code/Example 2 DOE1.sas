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
; 

proc ttest data = dubia_exp; 
	class dose; 
run; 
quit; 

/*what was the (approximate) power to detect a difference between
  the two groups. Note: our sample size per group is not even*/ 
proc power;
      twosamplemeans
	  test=diff
	  meandiff = 13.5
	  stddev = 10.9
	  ntotal = 9 
	  power = .; 
run; 

/* Again assuming the mean is true, look at this over a range
of values. */
proc power;
      twosamplemeans
	  test=diff
	  meandiff = 13.5
	  stddev = 10.9
	  ntotal = 5 to 50 by 2 
	  power = .; 
	  PLOT X=N MIN=1  MAX=50 STEP=1 MARKERS=none YOPTS= (REF=0.9 CROSSREF=yes);
run; 
