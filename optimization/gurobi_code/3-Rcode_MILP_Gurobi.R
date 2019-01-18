###Capital budget example
###Marr corporation
library(gurobi)
library(prioritizr)
model <- list()
model$obj        <- c(10,17,16,8,14)
model$modelsense <- "max"
model$rhs        <- c(160)
model$sense      <- c("<=")
model$vtype      <- "B"
model$A          <- matrix(c(48,96,80,32,64),nrow=1,byrow=T)
result <- gurobi(model, list())
print(result$status)
print(result$x)
print(result$objval)

####Set covering example
###Districts
model <- list()
model$obj        <- c(1,1,1,1,1,1,1)
model$modelsense <- "min"
model$rhs        <- rep(1,9)
model$sense      <- c(">=",">=",">=",">=",">=",">=",">=",">=",">=")
model$vtype      <- "B"
model$A          <- matrix(c(0,1,0,1,0,0,1,1,0,0,0,0,1,1,0,1,0,0,0,1,1,0,1,1,0,1,1,0,1,0,1,0,1,0,0,1,0,0,1,0,1,0,1,0,0,0,0,0,1,0,0,1,1,1,0,0,1,0,0,0,1,0,0),nrow=9,byrow=T)
result <- gurobi(model, list())
print(result$status)
print(result$x)
print(result$objval)

# Set poolsearch parameters
params                <- list()
params$PoolSolutions  <- 1024
params$PoolGap        <- 0.10
params$PoolSearchMode <- 2

# Save problem
gurobi_write(model, 'poolsearch_R.lp')


result <- gurobi(model, params, list())
result$pool
result.pool.matrix=matrix(nrow=8,ncol=7)
for (i in 1:8)
{result.pool.matrix[i,]=result$pool[[i]]$xn
}
round(result.pool.matrix)


#####Marr corporation example again with logical restrictions
model <- list()
model$obj        <- c(10,17,16,8,14)
model$modelsense <- "max"
model$rhs        <- c(160,1,2,1,0)
model$sense      <- c("<=",">=","=","<=",">=")
model$vtype      <- "B"
model$A          <- matrix(c(48,96,80,32,64,0,1,0,0,1,1,1,1,1,1,0,0,0,1,1,0,0,1,0,-1),nrow=5, byrow=T)
result <- gurobi(model, list())
print(result$status)
print(result$x)
print(result$objval)

####Fixed cost example
model <- list()
model$obj        <- c(1.2,1.8,2.2,-60,-200,-100)
model$modelsense <- "max"
model$rhs        <- c(2000,2000,2000,0,0,0)
model$sense      <- c("<=","<=","<=","<=","<=","<=")
model$vtype      <- c("C","C","C","B","B","B")
model$A          <- matrix(c(3,4,8,0,0,0,3,5,6,0,0,0,2,3,9,0,0,0,1,0,0,-400,0,0,0,1,0,0,-300,0,0,0,1,0,0,-50),nrow=6, byrow=T)
result <- gurobi(model, list())
print(result$status)
print(result$x)
print(result$objval)


####Facility example
cost=matrix(c(0,47,32,22,42.5,27,23,30,36.5,29.5,32,79.5,0,39,12.5,10.5,50,63,13.5,17,21,42,39,0,51.5,31.5,40.5,24,47.5,26,42.5,91,12.5,51.5,0,23,58,72,10,31,23,49,50,40.5,58,49,0,32.5,50,52,36.5,83.5,13.5,47.5,10,24,50,66.5,0,32), nrow=6,byrow=T)
capacity=c(16000, 20000, 10000,10000, 12000, 12000)
demand=c(3200, 2500, 6800, 4000, 9600, 3500, 5000, 1800, 7400, 2700)
fixed.cost=c(140000, 150000, 100000, 110000, 125000, 120000)
model <- list()
model$obj        <- c(as.numeric(t(cost)),fixed.cost)
model$modelsense <- "min"
model$rhs        <- c(rep(0,6),demand)
model$sense      <- c(rep('<=',6),rep('=',10))
model$vtype      <- c(rep("C",60),rep("B",6))
model$A          <- matrix(0,nrow=16,ncol=66)
for (i in 1:6)
{model$A[i,]=c(rep(0,10*(i-1)),rep(1,10),rep(0,10*(6-i)),rep(0,i-1),-capacity[i],rep(0,6-i))
}
for (j in 1:10)
{for (i in 1:6)
{model$A[(j+6),(10*(i-1)+j)] = 1
}}
result <- gurobi(model, list())
print(result$status)
print(result$x)
print(result$objval)
matrix(result$x[1:60],nrow=6,byrow=T)
result$x[61:66]
