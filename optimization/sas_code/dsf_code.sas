
libname optim 'G:\My Drive\Spring 1  2017 - Optimization\Code';
proc optmodel;
/* Define sets */
set <num> products;
set <num> departments;

/*Define parameters */
num maxTime {departments};
num costperhour {departments};
num price {products};
num demand {products};
num timeperdept {products, departments};

/* read data */

read data optim.dsf_department_data into
   departments=[department_id]
   maxTime  /* if name is same in data set, do not need to put '=' */
   costperhour=cost;

read data optim.dsf_product_data into
	products=[product_id]
	price
	demand;

read data optim.dsf_product_department_data into
	[product_id department_id]
	timeperdept = time;

	/* Define decision variables */
var prodquantity{products} >=0 integer;

/* Define implicit variables  */
impvar prodrevenue{p in products} = price[p]*prodquantity[p];
impvar prodhrsdept {p in products, d in departments} = timeperdept[p,d]*prodquantity[p];
impvar prodcost {p in products} = sum {d in departments} prodhrsdept[p,d]*costperhour[d];

/* Define objective function */
max profit = sum {p in products} (prodrevenue[p] - prodcost[p]);

/* Define constraints  */
con department_avail { d in departments}: sum {p in products} prodhrsdept[p,d] <= maxTime[d];
con product_demand {p in products}: prodquantity[p] <= demand[p];

solve;
create data optim.dsf_solution from [products] prodquantity;

	quit;


/* Get just positive values  */
data posprod;
 set optim.dsf_solution;
 where prodquantity>0;
 run;
