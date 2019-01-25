/*Example 2 Class 4*/ 

data crop; 
	input pesticide $2. variety $2. yield;
	datalines; 
N A 115
N A 101
L A 120
L A 127
H A 136
H A 130
N B 96
N B 94
L B 113
L B 108
H B 117
H B 124
N C 98
N C 109
L C 110
L C 122
H C 130
H C 128
;

*FIRST CHECK TO SEE IF THERE IS AN INTERACTION
*;
proc glm data = crop; 
	class pesticide variety; 
	model yield = pesticide variety variety*pesticide; 
run;
quit; 

*NO INTERACTION, REDUCE THE MODEL AND 
*MAKE ESTIMATES: NOTE THE WAY SAS CODES IT!;
*;
proc glm data = crop; 
	class pesticide variety; 
	model yield = pesticide variety; 
	lsmeans pesticide/cl  adjust=tukey;  
	lsmeans variety/cl adjust=tukey; 
run; 
quit; 


*ONE ISSUE: THE ABOVE CONTROLS EACH LSMEAN
*AT AN ALPHA = 0.05, BUT WE HAVE TWO TESTS
* + TEST FOR INTERACTION WE 
* NEED TO CONTROL FOR, SET ALPHA = 0.05/3 with 
* A Bonforoni adjustment now the entire error rate
* is controlled at a 0.05 level
*;
proc glm data = crop alpha=0.0167; 
	class pesticide variety; 
	model yield = pesticide variety; 
	lsmeans variety pesticide/cl  adjust=tukey;  
run; 
quit; 
