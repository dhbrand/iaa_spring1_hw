library(lpSolve)
f.names=c('Chairs','Desks','Tables')
f.obj=c(15,24,18)
f.con=matrix(c(4,6,2,3,5,7,3,2,4,1,0,0,0,1,0,0,0,1),nrow=6,byrow=T)
f.dir=c("<=","<=","<=","<=","<=","<=")
f.rhs = c(1850,2400,1500,360,300,100)
lp.model=lp (direction="max", f.obj, f.con, f.dir, f.rhs,compute.sens = 1)
lp.model$status
names(lp.model$solution)=f.names
lp.model$solution
lp.model$objval
