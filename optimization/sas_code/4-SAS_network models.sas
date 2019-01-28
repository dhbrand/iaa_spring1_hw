
/* Transportation Model  */
proc optmodel;
set Warehouse = /Atlanta Boston Chicago Denver/;
set Plant = /Minneapolis Pittsburgh Tuscon/;
number ShipCost{Plant,Warehouse} = [0.60 0.56 0.22 0.40
									0.36 0.30 0.28 0.58
									0.65 0.68 0.55 0.42];
number Capacity{Plant} = [9000 12000 13000];
number Demand{Warehouse} = [7500 8500 9500 8000];
var x{Plant,Warehouse}>=0;
min Cost = sum{i in Plant}(sum{j in Warehouse}
(ShipCost[i,j]*x[i,j]));
con Cap {i in Plant}: sum{j in Warehouse} x[i,j] <= Capacity[i];
con Dem {j in Warehouse}: sum{i in Plant} x[i,j] >= Demand[j];
solve;
print x;
print x.rc;
print Cap.dual Dem.dual;
quit;

/* Assignment Model  */
proc optmodel;
set Stroke = /Butterfly Breaststroke Backstroke Freestyle/;
set Swimmer = /Todd Betsy Lee Carly/;
number Time{Swimmer,Stroke} = [38 75 44 27
34 76 43 25
41 71 41 26
33 80 45 30];
var x{Swimmer,Stroke}>=0 binary;
min RelayTime = sum{i in Swimmer}(sum{j in Stroke}
(Time[i,j]*x[i,j]));
con MaxSwimmer {i in Swimmer}: sum{j in Stroke} x[i,j] = 1;
con MaxStroke {j in Stroke}: sum{i in Swimmer} x[i,j] = 1;
solve;
print x;
quit;

/*Transshipment Model */
proc optmodel;
set Factory = /Fac1 Fac2 Fac3/;
set DistCenter = /Dist1 Dist2/;
set Warehouse = /Ware1 Ware2 Ware3 Ware4 Ware5/;
number F2DCost{Factory,DistCenter} = [1.28 1.36
									  1.33 1.38
									  1.68 1.55];
number D2WCost{DistCenter,Warehouse} = [0.60 0.42 0.32 0.44 0.68
										0.57 0.30 0.4 0.38 0.72];
number Demand{Warehouse} = [1200 1300 1400 1500 1600];
var F2D{Factory,DistCenter}>=0,
D2W{DistCenter,Warehouse}>=0;
min Cost = sum{i in Factory}(sum{j in DistCenter}(F2DCost[i,j]*F2D[i,j])) + 
sum{k in DistCenter}(sum{l in Warehouse}(D2WCost[k,l]*D2W[k,l]));
con Cap {i in Factory}: sum{j in DistCenter} F2D[i,j] <= 2500;
con Dem {j in Warehouse}: sum{i in DistCenter}
D2W[i,j] >= Demand[j];
con Cons {j in DistCenter}: sum{k in Warehouse}D2W[j,k] -
sum{i in Factory}F2D[i,j] = 0;
solve;
print F2D D2W;
print F2D.rc D2W.rc;
quit;
