proc optmodel;
var Seeds>=0, Raisins>=0, Flakes>=0, Pecans>=0, Walnuts>=0;
min Cost=4*Seeds + 5*Raisins + 3*Flakes + 7*Pecans +6*Walnuts;
con Vitamins: 10*Seeds + 20*Raisins + 10*Flakes + 30*Pecans + 20*Walnuts>=20;
con Minerals: 5*Seeds + 7*Raisins + 4*Flakes + 9*Pecans + 2*Walnuts>=10;
con Protein: Seeds + 4*Raisins + 10*Flakes + 2*Pecans + Walnuts>=15;
con Calories: 500*Seeds + 450*Raisins + 160*Flakes + 300*Pecans + 500*Walnuts>=600;
solve with lp;
print Seeds Raisins Flakes Pecans Walnuts;
quit;

/* Illustrate shadow price  */

proc optmodel;
var Chairs>=0, Desks>=0, Tables>=0;
max Profit = 15*Chairs + 24*Desks + 18*Tables;
con Assembly: 3*Chairs + 5*Desks +7*Tables<=2400;
con Shipping: 3*Chairs + 2*Desks + 4*Tables<=1500;
con Fabrication: 4*Chairs+6*Desks+2*Tables<=1850;
con DemandC: Chairs <=360;
con DemandD: Desks<=300;
con DemandT: Tables<=100;
solve with lp ;
quit;

/* Increase fabrication by 1 hour  */
proc optmodel;
var Chairs>=0, Desks>=0, Tables>=0;
max Profit = 15*Chairs + 24*Desks + 18*Tables;
con Assembly: 3*Chairs + 5*Desks +7*Tables<=2400;
con Shipping: 3*Chairs + 2*Desks + 4*Tables<=1500;
con Fabrication: 4*Chairs+6*Desks+2*Tables<=1851;
con DemandC: Chairs <=360;
con DemandD: Desks<=300;
con DemandT: Tables<=100;
solve with lp ;
quit;

/* Increase fabrication by 2 hour  */
proc optmodel;
var Chairs>=0, Desks>=0, Tables>=0;
max Profit = 15*Chairs + 24*Desks + 18*Tables;
con Assembly: 3*Chairs + 5*Desks +7*Tables<=2400;
con Shipping: 3*Chairs + 2*Desks + 4*Tables<=1500;
con Fabrication: 4*Chairs+6*Desks+2*Tables<=1852;
con DemandC: Chairs <=360;
con DemandD: Desks<=300;
con DemandT: Tables<=100;
solve with lp ;
quit;

/* Increase Assembly by 1 hour  */
proc optmodel;
var Chairs>=0, Desks>=0, Tables>=0;
max Profit = 15*Chairs + 24*Desks + 18*Tables;
con Assembly: 3*Chairs + 5*Desks +7*Tables<=2401;
con Shipping: 3*Chairs + 2*Desks + 4*Tables<=1500;
con Fabrication: 4*Chairs+6*Desks+2*Tables<=1850;
con DemandC: Chairs <=360;
con DemandD: Desks<=300;
con DemandT: Tables<=100;
solve with lp ;
quit;


/* Get dual prices */
proc optmodel;
var Chairs>=0, Desks>=0, Tables>=0;
max Profit = 15*Chairs + 24*Desks + 18*Tables;
con Assembly: 3*Chairs + 5*Desks +7*Tables<=2400;
con Shipping: 3*Chairs + 2*Desks + 4*Tables<=1500;
con Fabrication: 4*Chairs+6*Desks+2*Tables<=1850;
con DemandC: Chairs <=360;
con DemandD: Desks<=300;
con DemandT: Tables<=100;
solve with lp ;
print fabrication.dual assembly.dual shipping.dual demandc.dual demandd.dual demandt.dual;
quit;

/* Get reduced cost */
proc optmodel;
var Chairs>=0, Desks>=0, Tables>=0;
max Profit = 15*Chairs + 24*Desks + 18*Tables;
con Assembly: 3*Chairs + 5*Desks +7*Tables<=2400;
con Shipping: 3*Chairs + 2*Desks + 4*Tables<=1500;
con Fabrication: 4*Chairs+6*Desks+2*Tables<=1850;
con DemandC: Chairs <=360;
con DemandD: Desks<=300;
con DemandT: Tables<=100;
solve with lp ;
print chairs.rc desks.rc tables.rc;
quit;


/* Blending Model */

proc optmodel;
var B>=0, C>=0, P>=0;
min Cost=0.5*B + 0.6*C + 0.7*P;
con Aroma: -3*B - 18*C + 7*P >=0;
con Strength: -B + 4*C + 2*P >=0;
con Total: B + C + P = 4000000;
con Brazil: B <=1500000;
con Colom: C <=1200000;
con Purivian: P <=2000000;
solve with lp;
print B C P;
print B.RC C.RC P.RC;
print B.dual C.dual P.dual Aroma.dual Strength.dual Total.dual
	Brazil.dual Colom.dual Purivian.dual;
quit;
