/*English data in class
  grp = 1 Teacher 1
  grp = 2 Teacher 2
*/
data class;
input class score;
cards; 
1 35 
2 52 
1 51 
2 87 
1 66 
2 76 
1 42 
2 62 
1 37 
2 81 
1 46
2 71  
1 60 
2 55 
1 55 
2 67 
1 53 
;
/*t-test on the above example*/
proc ttest data = class; 
	class class; /*class is the group assignment 1 = Class 1*/
			   /*2 = Class 2*/
	var  score; /*variable for the t-test*/ 
run; 

   proc power;
      twosamplemeans 
		 test=diff
         meandiff = 5 to 25 by 5 /* vary the mean difference*/
         stddev = 5 to 15 by 5   /* vary the standard deviation of the groups*/
         ntotal = . /*find the n */
         power = 0.9;  /*we want a 90% probability to find a differences
		 			     if the above is true*/
	  run;

 proc power;
      twosamplemeans 
		 test=diff
         meandiff = 5  
         stddev = 5   /* vary the standard deviation of the groups*/
		 NTOTAL = 1 to 300 by 5 
         POWER = .; 
		  /*now look at the graph*/
		  /* 90% is my cutoff ref=0.9)*/
		 PLOT X=N MIN=1  MAX=300 STEP=1 MARKERS=none YOPTS= (REF=0.9 CROSSREF=yes);
run;


 proc power;
      twosamplemeans 
		 test=diff
         meandiff = 5  
         stddev = 15   /* vary the standard deviation of the groups*/
		 NTOTAL = 1 to 400 by 5 
         POWER = .; 
		  /*now look at the graph*/
		  /* 90% is my cutoff ref=0.9)*/
		 PLOT X=N MIN=1  MAX=400 STEP=1 MARKERS=none YOPTS= (REF=0.9 CROSSREF=yes);
run;
