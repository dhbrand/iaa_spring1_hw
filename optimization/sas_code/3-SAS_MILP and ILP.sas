
/* Capital budget example....Marr corporation  */
proc optmodel;
var p1>=0 binary, p2>=0 binary, p3>=0 binary, p4>=0 binary, p5>=0 binary;
max NPV = 10*p1 + 17*p2 + 16*p3 + 8*p4 + 14*p5;
con cost: 48*p1 + 96*p2 + 80*p3 + 32*p4 + 64*p5 <=160;
solve;
print p1 p2 p3 p4 p5;
quit;

/* Set covering example...Districts  */
proc optmodel;
var s1 >=0 binary, s2 >=0 binary, s3 >=0 binary, s4 >=0 binary, s5 >=0 binary, s6 >=0 binary, s7 >=0 binary;
Min Sites = s1 +s2 +s3+s4+s5+s6+s7;
con District1: S2 + S4 + S7 >=1;
con District2: S1 + S6 + S7 >=1;
con District3: S2 + S6 + S7 >=1;
con District4: S2 + S3 + S5 + S6 >=1;
con District5: S1 + S3 + S5 >=1;
con District6: S1 + S4 + S6 >=1;
con District7: S1 + S7 >=1;
con District8: S3 + S4 + S5 >=1;
con District9:S1 + S5 >=1;
solve;
print s1 s2 s3 s4 s5 s6 s7;
quit;

/*Set covering example....show that there is more than one solution  */
proc optmodel;
var s1 >=0 binary, s2 >=0 binary, s3 >=0 binary, s4 >=0 binary, s5 >=0 binary, s6 >=0 binary, s7 >=0 binary;
Min Sites = s1 +s2 +s3+s4+s5+s6+s7;
con District1: S2 + S4 + S7 >=1;
con District2: S1 + S6 + S7 >=1;
con District3: S2 + S6 + S7 >=1;
con District4: S2 + S3 + S5 + S6 >=1;
con District5: S1 + S3 + S5 >=1;
con District6: S1 + S4 + S6 >=1;
con District7: S1 + S7 >=1;
con District8: S3 + S4 + S5 >=1;
con District9:S1 + S5 >=1;
solve with CLP / FINDALLSOLNS;
print s1 s2 s3 s4 s5 s6 s7;
quit;

/*Set covering example....print off all solutions  */

proc optmodel;
var s{1..7} binary;
Min Sites = sum{j in 1..7} s[j];
con District1: S[2] + S[4] + S[7] >=1;
con District2: S[1] + S[6] + S[7] >=1;
con District3: S[2] + S[6] + S[7] >=1;
con District4: S[2] + S[3] + S[5] + S[6] >=1;
con District5: S[1] + S[3] + S[5] >=1;
con District6: S[1] + S[4] + S[6] >=1;
con District7: S[1] + S[7] >=1;
con District8: S[3] + S[4] + S[5] >=1;
con District9:S[1] + S[5] >=1;
solve with CLP / FINDALLSOLNS;
print _NSOL_;
 print {j in 1.._NSOL_, i in 1..7} s[i].sol[j];
   create data solout from [sol]={j in 1.._NSOL_}
       {i in 1..7} <col("s"||i)=s[i].sol[j]> ;quit;

/* Marr corporation with logical restrictions  */
proc optmodel;
var P1 >=0 binary, P2 >=0 binary,
P3 >=0 binary, P4 >=0 binary,
P5 >=0 binary;
max NPV=10*P1 + 17*P2 + 16*P3 + 8*P4 + 14*P5;
con Cost: 48*P1 + 96*P2 + 80*P3 + 32*P4 + 64*P5 <= 160;
con International: P2 + P5 >= 1;
con ShortStaff: P1 + P2 + P3 + P4 + P5 = 2;
con CommonResources: P4 + P5 <= 1;
con ProjectDependent: P3 - P5 >= 0;
solve;
print P1 P2 P3 P4 P5;
quit;


/* Fixed Cost example  */
proc optmodel;
var F1 >=0, F2 >=0, F3 >=0, F1yes >=0 binary, F2yes >=0 binary,
F3yes >=0 binary;
max Profit=1.2*F1 + 1.8*F2 + 2.2*F3 - 60*F1yes - 200*F2yes - 100*F3yes;
con DepartmentA: 3*F1 + 4*F2 + 8*F3 <= 2000;
con DepartmentB: 3*F1 + 5*F2 + 6*F3 <= 2000;
con DepartmentC: 2*F1 + 3*F2 + 9*F3 <= 2000;
con FixedF1: F1 - 400*F1yes <= 0;
con FixedF2: F2 - 300*F2yes <= 0;
con FixedF3: F3 - 50*F3yes <= 0;
solve;
print F1 F2 F3 F1yes F2yes F3yes;
quit;

/* Another way of writing fixed cost example  */
proc optmodel;
var x{1..3}>=0, y{1..3}>=0 binary;
number p{1..3} = [1.2 1.8 2.2];
number A{1..3,1..3} = [3 4 8
3 5 6
2 3 9];
number b{1..3} = [2000 2000 2000];
number f{1..3} = [60 200 100];
number M{1..3} = [400 300 50];
max Profit = sum{j in 1..3} (p[j]*x[j] - f[j]*y[j]);
con Department {i in 1..3}: sum{j in 1..3}A[i,j]*x[j] <= b[i];
con Demand {j in 1..3}: x[j] - M[j]*y[j] <= 0;
solve;
print x y;
quit;


/* Yet another way to write fixed cost example  */
proc optmodel;
set Product = /Family1 Family2 Family3/;
set Department = /DepA DepB DepC/;
number Profit{Product} = [1.2 1.8 2.2];
number HrsReq{Department,Product} = [3 4 8
3 5 6
2 3 9];
number HrsCap{Department} = [2000 2000 2000];
number FixedCost{Product} = [60 200 100];
number Demand{Product} = [400 300 50];
var x{Product}>=0, y{Product}>=0 binary;
max TotalProfit =
sum{j in Product} (Profit[j]*x[j] - FixedCost[j]*y[j]);
con Dep {i in Department}:
sum{j in Product}HrsReq[i,j]*x[j] <= HrsCap[i];
con Dem {j in Product}: x[j] - Demand[j]*y[j] <= 0;
solve;
print x y;
quit;

/* Facility example  */
proc optmodel;
var x{1..6,1..10}>=0, y{1..6}>=0 binary;
number c{1..6,1..10}=[0 47 32 22 42.5 27 23 30 36.5 29.5
32 79.5 0 39 12.5 10.5 50 63 13.5 17
21 42 39 0 51.5 31.5 40.5 24 47.5 26
42.5 91 12.5 51.5 0 23 58 72 10 31
23 49 50 40.5 58 49 0 32.5 50 52
36.5 83.5 13.5 47.5 10 24 50 66.5 0 32];
number Capacity{1..6} = [16000 20000 10000
10000 12000 12000];
number Demand{1..10} = [3200 2500 6800 4000 9600
3500 5000 1800 7400 2700];
number FixedCost{1..6} = [140000 150000 100000
110000 125000 120000];
min Cost = sum{i in 1..6}(sum{j in 1..10}(c[i,j]*x[i,j]) +
FixedCost[i]*y[i]);
con Cap {i in 1..6}: sum{j in 1..10} x[i,j] - Capacity[i]*y[i] <= 0;
con Dem {j in 1..10}: sum{i in 1..6}x[i,j] = Demand[j];
solve;
print x y;
quit;
