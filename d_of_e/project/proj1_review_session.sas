/* assign effects for each factor level and then use a for loop to build
   the combinations
   
   E1 = 0% 
   E2 = 3%
   E3 = 4%
   P1 = 0%
   P2 = -0.5%
   
   E_i + P_j = Pr */

data combo;
/* exp prices (total effect of exp and price)  */
input e p pr;
cards;
1 1 .01
2 1 .04
3 1 .05
1 2 .005
2 2 .035
3 2 .045
;

proc glmpower data = combo;
class e p;
model pr = e p;
contrast 'e1 vs e2' 1 -1 0;
contrast 'e1 vs e2' e 1 0 -1 P*E
power = 0.80;
std = sqrt(0.01 * 0.99) /* P * (1 - P) comes from the base 1% visiting the parks; 
n = 1
/* probability is at most 4% for each individual factor but they can combine
   for multiple factors to be greater than 4% and even higher with an interaction
   
   should be enough power from several thousand examples*/
  
/* adding interactions */

/* assign effects for each factor level and then use a for loop to build
   the combinations
   
   E_i + P_j + E_i * P_j = Pr */


/* Possible Values for the Factors */


/* Location
   1 = 0.035 because its between raleigh and durham
   2 = 0.02 because its still in the raleigh bubble
   3 = 0.04 because its in most central location in raleigh
   4 = 0.025 because its still between durham and chapel hill    *****************************
   5 = 0.01 because its on the far side of raleigh from durham and chapel hill
   
   Price 
 $15  1 =  0.01 might be see as low compared to other offerings in the area
 $20  2 =  0.00 middle pricing probably gives a neutral effect
 $25  3 =  0.005 middle pricing probably gives a neutral effect         ***********************************
 $30  4 = -0.01 the highest price is most likely a deterant
   
 Experience
 family 1 = 0.03 there are a lot of families in raleigh and would be good alternative to other options
 thrill 2 = 0.04 rdu is growing and gaining a lot of millenials who would enjoy the thrill
 middle 3 = 0.00 rdu isnt a vacation destination and unlikely locals go to meager experience
 
 Other
 none     1 = 0.00  obvious
 arcade   2 = 0.025 might be good if its raining out
 puttputt 3 = 0.005 pretty cliche at this point in time and doesnt pair with zip lining customer
 both     4 = 0.03  additive from the previous 2

*/
