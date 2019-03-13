/*Question Set 1*/
*FOR USE WITH QUESTION SET 1
*RAT DIET PROBLEM
*
;

data one; 
  input diet body_weight @@;
cards; 
1 3.52 1 3.36 1 3.57
1 4.19 1 3.88 1 3.76
1 3.94 2 3.47 2 3.73
2 3.38 2 3.87 2 3.69
2 3.51 2 3.35 2 3.64
3 3.54 3 2.52 3 3.61
3 3.76 3 3.65 3 3.51
4 3.74 4 3.83 4 3.87
4 4.08 4 4.31 4 3.98
4 3.86 4 3.71
;

proc glm data=one;
  class diet;
  model body_weight = diet;
  lsmeans diet / cl adjust=tukey;
  estimate 'diet 3 - diet 2' diet 0 -1 1;
run;
quit;

proc power;
  onesamplefreq test=exact
    ntotal=2000
	nullp=0.1
	p=0.3
	power=.
	;
run;

proc power;
  onesamplefreq method=normal test=z
    ntotal=.
	nullp=0.1
	p=0.3
	power=.9
	;
run;

proc power;
  twosamplefreq test=fisher
    ntotal=.
	refproportion=0.1
	proportiondiff=0.2
	power=.9
	;
run;


data q2; 
input a b resp ;
cards; 
1 1 10 
1 2 20
2 1 50
2 2 60
;

proc glmpower data=q2;
  model resp = a b;
  power
    ntotal=100
	stddev=20
	power=.;
run;

proc glmpower data=q2;
  model resp = a b;
  power
    ntotal=.
	stddev=20
	power=.8;
run;

proc power;
  twosamplefreq test=fisher
    ntotal=150
	refproportion=0.01 0.05
	proportiondiff=0.02
	power=.
	;
run;

data rats;
 input dose sex obs n; 
 cards;
0  0  1 50
10 0  2 50
20 0  4 50
50 0  11 50
100 0 20 50
0   1  1  50
10  1  1  50
20  1  2  50
50  1  3  50
100 1  2  50
;

proc genmod data=rats;
  class dose sex ;
  model obs/n = dose|sex / dist=bin link=logit  type3 ;
*estimate 'hep c' hepc -1 1;
run;

proc genmod data=rats;
  class sex ;
  model obs/n = dose|sex / dist=bin link=logit  type3 ;
*estimate 'hep c' hepc -1 1;
run;

proc genmod data=rats;
  class sex ;
  model obs/n = dose|sex / dist=bin link=logit  type3 ;
  estimate 'dose 40' dose 40 0 0;
run;


