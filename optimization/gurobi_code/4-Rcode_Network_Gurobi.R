library(gurobi)
library(prioritizr)
##Transportation Model 
cost=matrix(c(.6,.36,.65,.56,.3,.68,.22,.28,.55,.4,.58,.42), ncol=4, byrow=F)
capacity=c(9000,12000,13000)
demand=c(7500,8500,9500,8000)
model=list()
model$obj=as.numeric(cost)
model$A=matrix(0,nrow=7,ncol=12)
temp=c(1,4,7,10)
for (i in 1:3)
{model$A[i,(i-1+temp)]=1}
temp2=c(1,2,3)
for (i in 1:4)
{model$A[i+3,(3*(i-1)+temp2)]=1}
model$rhs=c(capacity,demand)
model$sense=c(rep('<=',3),rep('>=',4))
model$modelsense="min"
result=gurobi(model,list())
matrix(result$x,nrow=3,byrow=F)
matrix(result$rc,nrow=3,byrow=F)
result$pi

###Assignment Model
time=matrix(c(38,34,41,33,75,76,71,80,44,43,41,45,27,25,26,30),nrow=4,byrow=F)
model=list()
model$obj=as.numeric(time)
model$A=matrix(0,nrow=8,ncol=16)
temp=c(1,5,9,13)
for (i in 1:4)
{model$A[i,(i-1+temp)]=1}
temp2=c(1,2,3,4)
for (i in 1:4)
{model$A[i+4,(4*(i-1)+temp2)]=1}
model$rhs=rep(1,8)
model$sense=rep('=',8)
model$modelsense="min"
result=gurobi(model,list())
matrix(result$x,nrow=4,byrow=F)
result$objval

###Transshipment Model
f2dcost=matrix(c(1.28,1.36,1.33,1.38,1.68,1.55),nrow=3,byrow=T)
d2wcost=matrix(c(0.6,0.42,0.32,0.44,0.68,0.57,0.3,0.4,0.38,0.72),nrow=2,byrow=T)
demand=c(1200,1300,1400,1500,1600)
model=list()
model$obj=c(as.numeric(f2dcost),as.numeric(d2wcost))
model$A=matrix(0,nrow=10,ncol=16)
for (i in 1:3)
{model$A[i,i]=1
model$A[i,i+3]=1}
for (i in 1:5)
{model$A[i+3,6+2*i-1]=1
model$A[i+3,6+2*i]=1}
temp=c(7,9,11,13,15)
temp2=c(8,10,12,14,16)
model$A[9,temp]=1
model$A[9,1:3]=-1
model$A[10,temp2]=1
model$A[10,4:6]=-1
model$rhs=c(rep(2500,3),demand,0,0)
model$sense=c(rep('<=',3),rep('>=',5),'=','=')
model$modelsense="min"
result=gurobi(model,list())
first.result=matrix(result$x[1:6],nrow=3,byrow=F)
rownames(first.result)=c('Fac1','Fac2','Fac3')
colnames(first.result)=c('Dist1','Dist2')
first.result
second.result=matrix(result$x[7:16],nrow=2,byrow=F)
rownames(second.result)=c('Dist1','Dist2')
colnames(second.result)=c('Ware1','Ware2','Ware3','Ware4','Ware5')
second.result
result$objval

