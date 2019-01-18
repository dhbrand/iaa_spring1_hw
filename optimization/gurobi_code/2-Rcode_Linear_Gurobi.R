library(gurobi)
library(prioritizr)
model <- list()
model$obj        <- c(4,5,3,7,6)
model$modelsense <- "min"
model$rhs        <- c(20,10,15,600)
model$sense      <- c(">=",">=",">=",">=")
model$vtype      <- "C"
model$A          <- matrix(c(10,20,10,30,20,5,7,4,9,2,1,4,10,2,1,500,450,160,300,500),nrow=4,byrow=T)
result <- gurobi(model, list())
print(result$status)
f.names=c('Seeds','Raisins','Flakes', 'Pecans','Walnuts')
names(result$x)=f.names
print(result$x)
print(result$objval)


####See if there are binding constraints
result$slack  ### the "slack" between optimized values and parameter values
result$pi   ### shadow price


###Illustration of shadow price
model <- list()
model$obj        <- c(15,24,18)
model$modelsense <- "max"
model$rhs        <- c(1850,2400,1500,360,300,100)
model$sense      <- c("<=","<=","<=","<=","<=","<=")
model$vtype      <- "C"
model$A          <- matrix(c(4,6,2,3,5,7,3,2,4,1,0,0,0,1,0,0,0,1),nrow=6,byrow=T)
result <- gurobi(model, list())
print(result$status)
f.names=c('Chairs','Desks','Tables')
names(result$x)=f.names
result$x
result$objval
result$slack

###Change fabrication by one hour
model$rhs        <- c(1851,2400,1500,360,300,100)
result <- gurobi(model, list())
result$objval
####Now increase by two hours
model$rhs        <- c(1852,2400,1500,360,300,100)
result <- gurobi(model, list())
result$objval
####Now keep fabrication the same but increase a nonbinding constraint
model$rhs        <- c(1850,2401,1500,360,300,100)
result <- gurobi(model, list())
result$objval

### To get shadow price or dual price
model$rhs        <- c(1850,2400,1500,360,300,100)
result <- gurobi(model, list())
result$pi

### To get reduced cost
model$rhs        <- c(1850,2400,1500,360,300,100)
result <- gurobi(model, list())
result$rc


####Blending Model

model <- list()
model$obj        <- c(0.5,0.6,0.7)
model$modelsense <- "min"
model$rhs        <- c(0,0,4000000,1500000,1200000,2000000)
model$sense      <- c(">=",">=","=","<=","<=","<=")
model$vtype      <- "C"
model$A          <- matrix(c(-3,-18,7,-1,4,2,1,1,1,1,0,0,0,1,0,0,0,1),nrow=6,byrow=T)
result <- gurobi(model, list())
print(result$status)
f.names=c('Brazilian','Colombian','Peruvian')
names(result$x)=f.names
print(result$x)
print(result$objval)
result$rc
result$pi





