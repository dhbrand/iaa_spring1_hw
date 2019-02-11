library(car) #to do our analysis using Anova which is not anova (stats)
###############################################################
# Generate a "binomial experiment"
# using Logistic regression
# so we can simulate power
#
###############################################################
set.seed('8675309') #Jenny I've got your number!
n <- 100 # total sample size
alpha <- 0.05 # basic level of significance

N <- rep(30,n) #number of repititions of the binomial experiment
               #brood = 30 in the example
betas1 <- seq(0,0.4,0.05) #dose response betas from 0 to 1
tests <- matrix(0,2000,ncol=length(betas1)) #need a place to save all of our
                                            #simulations
for (jj in 1:length(betas1)){
    for (ii in 1:2000) {
      x <- runif(n,0,2) #my x values fall raondomly on the interval [0,1]
      beta0 <- -2.197225     # background death rate

      logit <- beta0 + betas1[jj]*x #select the betas
      p <- 1/(1+exp(-logit))
      y <- rbinom(n,N,p)       # our 'model' is a binomial model with logistic regression
      
      fit.glm <- glm(cbind(y,N)~x,family="binomial") # defaults to logistic regression
      test <- Anova(fit.glm,test="LR",type=3) #Analysis of Deviance
      
   #  pval <- as.numeric(test[1,3]) #extract the p-value for the Analysis of Deviance for LR
      pval <- as.numeric(test[1,3]) #extract the p-value for the Analysis of Deviance for WALD
      
      tests[ii,jj] = (pval < alpha) # significant if the p-value is less than alpha
                                    
    }                               

}  
###############################################################
#
#Test just like our project! Not an example
#
###############################################################
set.seed('8675309') #Jenny I've got your number!
n <- 2000 # total sample size
alpha <- 0.05 # basic level of significance

N <- rep(1,n) #number of repititions of the binomial experiment

betas1 <- c(0,0.5,1.0,1.5);  #logit for each group
tests <- matrix(0,2000,ncol=length(betas1)) #need a place to save all of our
                                            #testssimulations
for (ii in 1:2000) {
    x <- rep(1:4,n/4) #my x values fall raondomly on the interval [0,1]
    beta0 <-  -3.59512     #my betas - we need to specify them just like proc glmpower
    
    logit <- beta0 + betas1[x] #select the betas
    p <- 1/(1+exp(-logit))
    y <- rbinom(n,N,p)       # our 'model' is a binomial model with logistic regression
    
    fit.glm <- glm(cbind(y,N)~as.factor(x),family="binomial") # defaults to logistic regression
    test2 <- summary(fit.glm)$coefficients #extract estimated coefficients from the table 
    test <- Anova(fit.glm,test="LR",type=3) #Analysis of Deviance
    
    #   pval <- as.numeric(test[1,3]) #extract the p-value for the Analysis of Deviance for LR
    pval <- as.numeric(test[1,3]) #extract the p-value for the Analysis of Deviance for WALD
    
    tests[ii,1] = (pval < alpha) # significant if the p-value is less than alpha - overall test
    tests[ii,2] = (test2[2,4] < alpha) #  significant if the p-value is less than alpha - first parameter
    tests[ii,3] = (test2[3,4] < alpha) #  significant if the p-value is less than alpha - second parameter
    tests[ii,4] = (test2[4,4] < alpha) #  significant if the p-value is less than alpha - third parameter
  
}                               
  


###############################################################
# Generate a "Poisson experiment"
# using log-linear regression
#
###############################################################

set.seed('8675309') #Jenny I've got your number!
n <- 100 # total sample size
alpha <- 0.05 # basic level of significance

betas1 <- seq(0,0.05,0.01)
tests <- matrix(0,2000,ncol=length(betas1)) #need a place to save all of our
#simulations
for (jj in 1:length(betas1)){
  for (ii in 1:2000) {
    x <- runif(n,0,10) #my x values fall raondomly on the interval [0,10]
                       # so we have average miles over between 0 and 10mph
    beta0 <- 1     #my betas - we need to specify them just like proc glmpower
    
    logit <- beta0 + betas1[jj]*x #select the betas
    lambda <- exp(logit)
    y <- rpois(n,lambda)       # our 'model' is a poisson model with log-linear regression
    
    fit.glm <- glm(y~x,family="poisson") # defaults to log-linear regression
    test <- Anova(fit.glm,test="LR",type=3) #Analysis of Deviance use "LR"
    
    pval <- as.numeric(test[1,3]) #extract the p-value for the Analysis of Deviance
    tests[ii,jj] = (pval < alpha) # significant if the p-value is less than alpha
    
  }                               
  
}