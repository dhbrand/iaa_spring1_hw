/* Creates the experiment grid - 5 by 4 by 2 by 3 for 120 unique combinations */
data parkexp(keep=L P E O RR);
	array location {5} (0.035 0.02 0.04 0.025 0.01);
	array price {4} (0.01 0 -0.005 -0.01);
	array experience {2} (0.03 0.04);
	array other {3} (0 0.025 0.005);
	do L = 1 to 5;
		do P = 1 to 4;
			do E = 1 to 2;         *essentially dropped option 3;
				do O = 1 to 3;     *essentially dropped option 4;
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
	contrast 'location 2 VS. 4' L 0 1 0 -1 0; 
	contrast 'location 2 VS. 5' L 0 1 0 0 -1;
	contrast 'location 3 VS. 4' L 0 0 1 -1 0;
	contrast 'location 3 VS. 5' L 0 0 1 0 -1;
	contrast 'location 4 VS. 5' L 0 0 0 1 -1;

	* 4 prices creates 6 comparisons;
	*contrast 'price 1 VS. 2' P 1 -1 0 0;
	contrast 'price 1 VS. 3' P 1 0 -1 0;
	contrast 'price 1 VS. 4' P 1 0 0 -1;
	*contrast 'price 2 VS. 3' P 0 1 -1 0;        
	contrast 'price 2 VS. 4' P 0 1 0 -1;
	*contrast 'price 3 VS. 4' P 0 0 1 -1;

	* 3 experiences creates 3 comparisons;
	contrast 'experience 1 VS. 2' E 1 -1 0;
	*contrast 'experience 1 VS. 3' E 1 0 -1;
	*contrast 'experience 2 VS. 3' E 0 1 -1;

	* 4 others creates 6 comparisons;
	contrast 'other 1 VS. 2' O 1 -1 0 0;
	contrast 'other 1 VS. 3' O 1 0 -1 0;
	*contrast 'other 1 VS. 4' O 1 0 0 -1;
	contrast 'other 2 VS. 3' O 0 1 -1 0;
	*contrast 'other 2 VS. 4' O 0 1 0 -1;
	*contrast 'other 3 VS. 4' O 0 0 1 -1;

	* Interactions effects of interest;
	*contrast 'price vs experience' P 1 0 0 -1 P*E 0.5 0.5 0 0 0 0 -0.5 -0.5;
	*contrast 'price vs other' P 1 0 0 -1 P*O 0.5 0 0.5 0 0 0 0 0 0 -0.5 0 -0.5;

	power
		alpha= 0.002941 /* 0.05 divided by 17 */
		power= 0.80
		ntotal=.
		stddev= 0.099499;  * 1% = p,  sqrt(p(1-p);
run;

/* This section calculates Euclidean distance for each person to 
   each location and then converts units to miles and then assigns blocks */
data rduch_wj(keep=ID block);
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
	mind = min(d1m, d2m, d3m, d4m, d5m);

	/* assign blocks, number of blocks to use and the cutoffs need to be determined */
	if mind < 4 then block = 1;
	else if mind < 8 then block = 2;
	else if mind < 12 then block = 3;
	else block = 4;
run;

proc univariate data=rduch_wj;
	var mind;
	histogram mind;
run;

/* Steps to create final output dataset */
proc sort data=rduch_wj;
	by block;
run;

proc surveyselect data=rduch_wj
      method=srs n=1680
      seed=1953 out=SampleStrata;
   strata block;
run;

data parkexp2(keep=block L P E O );
	do block = 1 to 4;
		do i = 1 to 14;  * # of replicates;
			do L = 1 to 5;
				do P = 1 to 4;
					do E = 1 to 2;         
						do O = 1 to 3;     
							output;
						end;
					end;
				end;
			end;
		end;
	end;
run;

data doe.final(keep=ID L P E O);
	merge samplestrata parkexp2;
	by block;
run;
