library(gurobi)
library(prioritizr)
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
 print(result$x)
 print(result$objval)
 
 
 
 