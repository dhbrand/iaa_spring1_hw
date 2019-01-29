data doe.part2(drop=blank);
	infile "C:\Users\Bill\Documents\GitHub\og_sp1_hw\d_of_e\data\results.csv" dlm="," dsd;
	input blank id long lat age race $ sex $ income $ location price experience other will_attend;
run;

data doe.part2;
	set doe.part2;
	if _n_ > 1;
run;

