data class;
input class score;
cards;
0 60
20 58
40 40
0 90
20 74
40 58
0 74
20 50
40 25
0 82
20 65
40 30
20 68
40 42
;

data test1;
  set class;
  where class = 0 or class = 40;
run;



proc ttest data = test1; 
	class class; 
	var  score; 

proc power;
  twosamplemeans 
	 test=diff
     meandiff = 37.5 
     stddev = 12.7560
     ntotal = 9 
     power = .; 
  run;

/* 0.930 */

proc power;
  twosamplemeans 
	 test=diff
	 alpha= 0.01
     meandiff = 37.5
     stddev = 12.7560
     ntotal = 9 
     power = .; 
  run;

/* 0.667 */

proc power;
  twosamplemeans 
	 test=diff_satt
	 alpha= 0.01 0.05 
     meandiff = 37.5 
     stddev = 12.7560 
     ntotal = 9 
     power = .; 
  run;

/* for a=0.01 p=0.559 and for a=0.04 p=0.905 */
