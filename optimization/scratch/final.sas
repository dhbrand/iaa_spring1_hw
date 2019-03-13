/* IAA Media needs to decide how many spots (30 sec commercials) to 
schedule in each one of the available TV shows during a two-day planning 
period for its main customer: Optim (number of spots must be whole numbers…cannot have a percent 
of a spot). IAA does not allow more than 10 spots for a given Show/Day combination. 
Optim would like to reach as many as possible males that are between the 
ages of 30-50 years old. Optim’s budget is $10,000, which means an advertisement 
plan cannot cost more than this budget. Find out how many commercials should 
appear in each of the Show/Day combinations shown below. The available TV shows, 
their cost (dollars per one spot) and expected audience (millions per one spot) are as follows: */

 

/* Shows Day Cost($) Males (in millions per spot)
   1      1   300     0.5
   2      1   200     2
   3      1   500     0.2
   4      1   130     1
   1      2   200     8
   2      2   210     7
   3      2   140     6
   4      2   30      2
*/

/*constraints:  1) no more than 10 commercials per show/day combo
                2) total_cost must be less than or equal to $10,000
*/
proc optmodel;
set show = /s1 s2 s3 s4/;
set day = /d1 d2/;
number cost{show,day} = [300 200
                         200 210
                         500 140
                         130  30];
number male{show,day} = [0.5 8.0
                         2.0 7.0
                         0.2 6.0
                         1.0 2.0];

var x{show,day} >=0 <=10 integer;

con market: sum{i in show}(sum{j in day}(x[i,j]*cost[i,j])) <= 10000;

max spots = sum{i in show}(sum{j in day}(x[i,j]*male[i,j]));

solve;
print x;
print x.rc x.dual;
print market.dual;
quit;


