
library(magrittr)
library(dplyr)

top <- 1:10
### file import
letor <- read.csv("train.csv",header=T)
which(is.na(letor)==TRUE)
table(letor$rel)

### sample training & test set
set.seed(231)
ind <- sample(1:nrow(letor),10000)
letor_train <- letor[ind,]

### treat levels 0 & 1 as 0 and the rest as 1 according to the number of obs
letor_train_bin <- letor_train %>% mutate(rel = ifelse(rel<2,0,1))

### fit a logistic regression
letor_glm <- glm(rel~.,letor_train_bin,family = binomial)
summary(letor_glm)

### sigularity occurs, which indicates some of the variables have perfect colinearity, that is to say, some of the variables are exact linear combinations of others. However, in this project we are more interested in the predictive ability of our model ranther than individual coefficients. Aliased variables which just do not contribute to the model will not affect our model accuracy.
### Still, 136 features are way too inefficient and expansive to do computations, so the motivation is that we want a shrinkage on these features.

### LASSO on variable selection
library(glmnet)
attach(letor_train_bin)
set.seed(231)
x <- model.matrix(letor_glm)
fit.lasso <- glmnet(x,rel,alpha=1)
fit.lasso.cv <- cv.glmnet(x,rel)
{plot(fit.lasso, xvar="lambda",xlim=c(-10,-2))
text(-10,coef(fit.lasso)[-1,length(fit.lasso$lambda)],labels=colnames(x),cex=0.4)
abline(v=log(fit.lasso.cv$lambda.min), col="red")
mtext("CV estimate", side=1, at=log(fit.lasso.cv$lambda.min), cex=.6)}
coef_lasso <- fit.lasso.cv$glmnet.fit$beta[, match(fit.lasso.cv$lambda.min, fit.lasso.cv$lambda)]
## remaining features
names(coef_lasso[coef_lasso!=0])

### Use our new model to predit
nQueries <- 0
sumPrecision <- numeric(length(top))
sumNDCG <- numeric(length(top))
for (testFile in list.files(path = "test_csv")) {
  letor_test <- read.csv(paste("test_csv", testFile, sep="/"), header = T)
  letor_test_bin <- letor_test %>% mutate(rel = ifelse(rel<2,0,1))
  x_test <- model.matrix(~.-rel,data=letor_test_bin)
  letor_glm_pred <- predict(fit.lasso, x_test,s=fit.lasso.cv$lambda.min, type="response")
  if (max(letor_test$rel) == 0) next;
  for (k in 1:length(top)) {
    ind <- order(letor_glm_pred,decreasing = T)[1:top[k]]
    precision <- sum(letor_test_bin$rel[ind])/top[k]
    dcg <- 0.0
    for (i in 1:top[k]) {
      dcg <- dcg + (2^letor_test$rel[ind[i]]-1) * log(2.0) / log(i+1)
    }
    idcg <- 0.0
    ind <- order(letor_test$rel, decreasing = T)
    if (letor_test$rel[ind[1]] == 0) next
    for (i in 1:top[k]) {
      idcg <- idcg + (2^letor_test$rel[ind[i]]-1) * log(2.0) / log(i+1)
    }
    sumPrecision[k] <- sumPrecision[k] + precision
    sumNDCG[k] <- sumNDCG[k] + dcg / idcg
  }
  nQueries <- nQueries + 1
}
## We first evaluate the top precision:
precision <- sumPrecision / nQueries
print("Precisions (@1 - 10):")
print(precision)

## Next we evaluate the top NDCG:
ndcg <- sumNDCG / nQueries
print("NDCGs (@1 - 10):")
print(ndcg)


