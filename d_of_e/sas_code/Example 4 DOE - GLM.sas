/*Example 4 Using Fact ex*/ 
PROC FACTEX;
 	FACTORS Intro Duration Goto Color Postage Rewards;
	MODEL resolution=5; *resolution 5 design; 
	SIZE design = 32;   *2^(6-1) = 32 required to 
					    *create design; 
	EXAMINE confounding design; 
	OUTPUT OUT = designM /*output our info in a 
						   human readable form*/
		Intro		nvals = (0 2.99)
		Duration 	nvals = (9 12)
		Goto		nvals = (4.99 7.99)
		Color 		cvals = ("white" "blue")
	    Postage 	cvals = ("first class" "third class")
		Rewards 	cvals = ("yes" "no");
RUN; 
QUIT;


/* what about a resolution 4 design*/
PROC FACTEX;
 	FACTORS Intro Duration Goto Color Postage Rewards;
	MODEL resolution=4; *resolution 4 design; 
	SIZE design = 16;   *2^(6-2) = 32 required to 
					    *create design; 
	EXAMINE confounding design; 
	OUTPUT OUT = designM /*output our info in a 
						   human readable form*/
		Intro		nvals = (0 2.99)
		Duration 	nvals = (9 12)
		Goto		nvals = (4.99 7.99)
		Color 		cvals = ("white" "blue")
	    Postage 	cvals = ("first class" "third class")
		Rewards 	cvals = ("yes" "no");
RUN; 
QUIT;
