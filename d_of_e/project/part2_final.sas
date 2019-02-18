/*Final code for Orange Team 1*/
proc glm data=doe.part2_with_blocks; 
	class  block location price experience other ; 
	model will_attend =  block location price experience other /;
* 5 locations creates 10 comparisons;
	estimate 'location 1 VS. 2' location 1 -1 0 0 0; 
	estimate 'location 1 VS. 3' location 1 0 -1 0 0;
	estimate 'location 1 VS. 4' location 1 0 0 -1 0;
	estimate 'location 1 VS. 5' location 1 0 0 0 -1;
 	estimate 'location 2 VS. 3' location 0 1 -1 0 0;
	estimate 'location 2 VS. 4' location 0 1 0 -1 0; 
	estimate 'location 2 VS. 5' location 0 1 0 0 -1;
	estimate 'location 3 VS. 4' location 0 0 1 -1 0;
	estimate 'location 3 VS. 5' location 0 0 1 0 -1;
	estimate 'location 4 VS. 5' location 0 0 0 1 -1;

	* 4 prices creates 6 comparisons;
	estimate 'price 1 VS. 2' price 1 -1 0 0;
	estimate 'price 1 VS. 3' price 1 0 -1 0;
	estimate 'price 1 VS. 4' price 1 0 0 -1;
	estimate 'price 2 VS. 3' price 0 1 -1 0;        
	estimate 'price 2 VS. 4' price 0 1 0 -1;
	estimate 'price 3 VS. 4' price 0 0 1 -1;

	* 2 experiences creates 1 comparisons;
	estimate 'experience 1 VS. 2' experience 1 -1 0;

	* 3 others creates 3 comparisons;
	estimate 'other 1 VS. 2' other 1 -1 0 0;
	estimate 'other 1 VS. 3' other 1 0 -1 0;
	estimate 'other 2 VS. 3' other 0 1 -1 0;
run; 
quit; 







proc glmpower data=doe.part2_with_blocks; 
	class  block location price experience other ; 
	model will_attend =  block location price experience other ;

	* 5 locations creates 10 comparisons;
	contrast 'location 1 VS. 2' location 1 -1 0 0 0; 
	contrast 'location 1 VS. 3' location 1 0 -1 0 0;
	contrast 'location 1 VS. 4' location 1 0 0 -1 0;
	contrast 'location 1 VS. 5' location 1 0 0 0 -1;
 	contrast 'location 2 VS. 3' location 0 1 -1 0 0;
	contrast 'location 2 VS. 4' location 0 1 0 -1 0; 
	contrast 'location 2 VS. 5' location 0 1 0 0 -1;
	contrast 'location 3 VS. 4' location 0 0 1 -1 0;
	contrast 'location 3 VS. 5' location 0 0 1 0 -1;
	contrast 'location 4 VS. 5' location 0 0 0 1 -1;

	* 4 prices creates 6 comparisons;
	contrast 'price 1 VS. 2' price 1 -1 0 0;
	contrast 'price 1 VS. 3' price 1 0 -1 0;
	contrast 'price 1 VS. 4' price 1 0 0 -1;
	contrast 'price 2 VS. 3' price 0 1 -1 0;        
	contrast 'price 2 VS. 4' price 0 1 0 -1;
	contrast 'price 3 VS. 4' price 0 0 1 -1;

	* 2 experiences creates 1 comparisons;
	contrast 'experience 1 VS. 2' experience 1 -1 0;

	* 3 others creates 3 comparisons;
	contrast 'other 1 VS. 2' other 1 -1 0 0;
	contrast 'other 1 VS. 3' other 1 0 -1 0;
	contrast 'other 2 VS. 3' other 0 1 -1 0;
	
	power
		alpha= 0.00217 /* 0.05 divided by 17 */
		power= .
		ntotal=6720
		stddev= 0.099499;  * 1% = p,  sqrt(p(1-p);
run; 
quit; 



/* Final recommendations after group discussion:
   location 2
   other 3
   price 2
   experience 2 */



