proc power;
	onesamplefreq method=normal test=adjz
	nullp=0.01
	p=0.011 to 0.04 by 0.001
	alpha=0.025
	power=0.8
	ntotal=.;
run;
end;

data doe.rduch_wj;
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
