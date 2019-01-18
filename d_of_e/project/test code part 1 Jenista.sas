/* Creates the experiment grid - 5 by 4 by 3 by 4 for 240 unique combinations */
data parkexp(keep=L P E O RR);
	array location {5} (0.035 0.02 0.04 0.025 0.01);
	array price {4} (0.01 0 -0.005 -0.01);
	array experience {3} (0.03 0.04 0);
	array other {4} (0 0.025 0.005 0.03);
	do L = 1 to 5;
		do P = 1 to 4;
			do E = 1 to 3;
				do O = 1 to 4;
					RR = location[L] + price[P] + experience[E] + other[O];      
					output;
				end;
			end;
		end;
	end;
run;

proc glmpower data=parkexp;
	class L P E O;
	model RR = L P E O; 

	* 5 locations creates 10 comparisons;
	contrast 'location 1 VS. 2' L 1 -1 0 0 0; 
	contrast 'location 1 VS. 3' L 1 0 -1 0 0;
	contrast 'location 1 VS. 4' L 1 0 0 -1 0;
	contrast 'location 1 VS. 5' L 1 0 0 0 -1;
 	contrast 'location 2 VS. 3' L 0 1 -1 0 0;
	contrast 'location 2 VS. 4' L 0 1 0 -1 0;    *something about this line is resulting in invalid input;
	contrast 'location 2 VS. 5' L 0 1 0 0 -1;
	contrast 'location 3 VS. 4' L 0 0 1 -1 0;
	contrast 'location 3 VS. 5' L 0 0 1 0 -1;
	contrast 'location 4 VS. 5' L 0 0 0 1 -1;

	* 4 prices creates 6 comparisons;
	contrast 'price 1 VS. 2' P 1 -1 0 0;
	contrast 'price 1 VS. 3' P 1 0 -1 0;
	contrast 'price 1 VS. 4' P 1 0 0 -1;
	contrast 'price 2 VS. 3' P 0 1 -1 0;         *something about this line is resulting in invalid input;
	contrast 'price 2 VS. 4' P 0 1 0 -1;
	contrast 'price 3 VS. 4' P 0 0 1 -1;

	* 3 experiences creates 3 comparisons;
	contrast 'experience 1 VS. 2' E 1 -1 0;
	contrast 'experience 1 VS. 3' E 1 0 -1;
	contrast 'experience 2 VS. 3' E 0 1 -1;

	* 4 others creates 6 comparisons;
	contrast 'other 1 VS. 2' O 1 -1 0 0;
	contrast 'other 1 VS. 3' O 1 0 -1 0;
	contrast 'other 1 VS. 4' O 1 0 0 -1;
	contrast 'other 2 VS. 3' O 0 1 -1 0;
	contrast 'other 2 VS. 4' O 0 1 0 -1;
	contrast 'other 3 VS. 4' O 0 0 1 -1;

	power
		alpha= 0.0125 0.002 /*(0.05 / 4 tests), 4 might be wrong here - could be 25 (0.002) */
		power= 0.80
		ntotal=.
		stddev= 0.099499;  * 1% = p,  sqrt(p(1-p);
run;

/* This section calculates Euclidean distance for each person to 
   each location and then converts units to miles */
data rduch_wj;
	set doe.rduch;
	d1 = sqrt((long-(-78.878130))**2 + (lat-35.89314)**2);
	d2 = sqrt((long-(-78.875880))**2 + (lat-35.74628)**2);
	d3 = sqrt((long-(-78.676540))**2 + (lat-35.77240)**2);
	d4 = sqrt((long-(-79.054280))**2 + (lat-35.90535)**2);
	d5 = sqrt((long-(-78.575981))**2 + (lat-35.86696)**2);
	ref = sqrt((-78.875880-(-78.878130))**2 + (35.74628-35.89314)**2);
	d1m = d1*10.15/ref;   *10.15 is the distance in miles between locations 1 and 2 from an online calculation tool;
	d2m = d2*10.15/ref;
	d3m = d3*10.15/ref;
	d4m = d4*10.15/ref;
	d5m = d5*10.15/ref;
run;

data rduch_final(keep= ID L P E O);
	set rduch_wj;
	retain block L P E O 1;
	sample = 8000;    /* hopefully this will be a multiple of 240 so that each block has the entire experiment */

	/* Subsetting IF to only allow random IDs through at a rate equal to the percentage of our sample size to the population */
	if rand('UNIFORM') < sample/1507600 and n < sample;
	
	/* update increments */
	n+1;
	output;
	if O < 4 then O+1;
	else do;
		O=1;
		if E < 3 then E+1;
		else do;
			E=1;
			if P < 4 then P+1;
			else do;
				P=1;
				if L < 5 then L+1;
				else do;
					L=1;
					block+1;
				end;
			end;
		end;
	end;
run;
