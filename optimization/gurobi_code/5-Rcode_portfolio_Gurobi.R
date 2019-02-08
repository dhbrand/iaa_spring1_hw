library(gurobi)
library(prioritizr)

setwd('G:\\My Drive\\Spring 1  2017 - Optimization')
port=read.table('portfolio_r.csv',sep=',',header=T)
mean.vec=apply(port,2,mean)
cov.vec=cov(port)

model <- list()

model$A     <- matrix(c(1,1,1,1,1,mean.vec),nrow=2,byrow=T)
model$Q     <- cov.vec
model$obj   <- c(0,0,0,0,0)
model$rhs   <- c(1,0.015)
model$sense <- c('=', '>=')
result <- gurobi(model,list())
result.names=c('Computer','Chemical','Power','Auto','Electronics')
names(result$x)=result.names
result$objval




################################ Efficient Frontier
##############################################

stocks=read.table('G:\\My Drive\\Spring 1  2017 - Optimization\\stocks_r.csv',sep=',',header=T)
temp=stocks[,1]
temp2=as.Date(temp,'%m/%d/%Y')
year.s=as.numeric(format(temp2,'%Y'))
month.s=as.numeric(format(temp2,'%m'))
id=paste(month.s,year.s,sep='')
stocks.dat=cbind(id,stocks[,-1])
alldat=aggregate(.~id,data=stocks.dat,sum)
all.dat2=alldat[,-1]
all.dat2=all.dat2[,-5]
mean.vec=apply(all.dat2,2,mean)
cov.vec=cov(all.dat2)


A.1     <- matrix(c(rep(1,length(mean.vec)),mean.vec),nrow=2,byrow=T)
A.2     <-diag(length(mean.vec))
model$A <- rbind(A.1,A.2)
model$Q     <- cov.vec
model$obj   <- rep(0,length(mean.vec))
model$sense <- c('=','=', rep('>=',length(mean.vec)))
param=seq(0.26,0.4, by=0.020)
eff.front.weight=matrix(nrow=length(param),ncol=length(mean.vec))
eff.front.return=vector(length=length(param))
eff.front.risk=param
for (i in 1:length(param))
{
  model$rhs <- c(1,param[i],rep(0,length(mean.vec)))
  result <-gurobi(model,list())
  eff.front.return[i]=sum(result$x*mean.vec)
  eff.front.risk[i]=sqrt(result$objval)
  eff.front.weight[i,]=result$x
}
   

plot(eff.front.risk,eff.front.return,type='l')