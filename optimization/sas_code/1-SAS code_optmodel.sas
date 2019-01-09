proc optmodel;
/* declare variables */
var Chairs>=0, Desks>=0, Tables>=0;
/* maximize objective function (profit) */
max Profit = 15*Chairs + 24*Desks + 18*Tables;
/* subject to constraints */
con Assembly: 3*Chairs + 5*Desks +7*Tables<=2400;
con Shipping: 3*Chairs + 2*Desks + 4*Tables<=1500;
con Fabrication: 4*Chairs+6*Desks+2*Tables<=1850;
con DemandC: Chairs <=360;
con DemandD: Desks<=300;
con DemandT: Tables<=100;
/* solve LP using primal simplex solver */
solve with lp ;
/* display solution */
print Chairs Desks Tables;
quit;
