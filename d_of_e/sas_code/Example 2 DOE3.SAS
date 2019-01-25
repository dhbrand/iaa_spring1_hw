/* Cookie Chewiness for example 2
   class 3*/ 
data chew; 
	input chef kitchen flour chew @@; 
	cards; 
	1 1 1 1.620 1 1 1 1.342 1 2 1 2.669 1 2 1 2.687
	1 2 1 2.155 1 2 1 4.000 1 1 2 3.228 1 1 2 5.762
	1 2 2 6.219 1 2 2 8.207 1 1 3 6.615 1 1 3 8.245
	1 1 3 8.077 1 2 3 11.37 2 1 1 2.282 2 2 1 4.233
	2 2 1 4.664 2 2 1 3.002 2 2 1 4.506 2 2 1 6.385
	2 2 1 3.696 2 1 2 5.080 2 1 2 4.741 2 1 2 4.522
	2 2 2 4.647 2 2 2 4.999 2 2 2 5.939 2 1 3 8.240
	2 1 3 6.330 2 1 3 9.453 2 1 3 7.727 2 2 3 7.809
	2 2 3 8.942
;

proc glm data = chew; 
	*Three class variables; 
	class chef kitchen flour; 
	*Only main effects for now;
	model chew = flour chef kitchen; 
	lsmeans flour/cl adjust=bon;
	*above line adjusts using a Bonferroni adjustment; 
	run; 
quit; 
