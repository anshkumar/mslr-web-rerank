###################################
##### PSTAT 231 Final Project #####
##        Author: Sen LEI        ##
###################################





##### DATA lector #####
lector <- read.csv("train.csv", header = T)

# Data Modification 
lector$rel <- as.ordered(lector$rel)


set.seed(231)
test_index <- sample(1:dim(lector)[1], 700000)
lector_train <- lector[test_index, ]
#lector_train <- lector[,]

## Assign the Data Set that we are using
dt <- lector_train


##### Continuation Ratio Model #####
library(glmnetcr)

Y <- dt$rel
X <- dt[, 2:dim(dt)[2]]

CRM <- glmnetcr(X, Y)
#print(CRM)
#plot(CRM, xvar = "step", type = "bic")
#plot(CRM, xvar = "step", type = "coefficients")

BIC.step <- select.glmnetcr(CRM)
AIC.step <- select.glmnetcr(CRM, which = "AIC")

hat <- fitted(CRM, s = BIC.step)
table(hat$class)

## Test
top <- 1:10
nQueries <- 0
sumPrecision <- numeric(length(top))
sumNDCG <- numeric(length(top))
for (testFile in list.files(path = "test_csv")) {
  letor_test <- read.csv(paste("test_csv", testFile, sep="/"), header = T)
  if (max(letor_test$rel) == 0) next
  X_test <- letor_test[, 2:dim(letor_test)[2]]
  pred <- fitted(CRM, newx=X_test, s=BIC.step)

  pred_exp <-  pred$probs %*% as.matrix(as.numeric(colnames(pred$probs)), 4, 1)
  rank <- order(pred_exp, decreasing=T)
  rel_new <- ifelse(letor_test$rel<=1, 0, 1)
  for (k in 1:length(top)) {
    precision <- sum(rel_new[rank[1:top[k]]])/top[k]
    dcg <- 0.0
    ind <- order(letor_test$rel, decreasing = T)
    for (i in 1:top[k]) {
      dcg <- dcg + (2^letor_test$rel[rank[i]]-1) * log(2.0) / log(i+1)
    }
    idcg <- 0.0
    for (i in 1:top[k]) {
      idcg <- idcg + (2^letor_test$rel[ind[i]]-1) * log(2.0) / log(i+1)
    }
    sumPrecision[k] <- sumPrecision[k] + precision
    sumNDCG[k] <- sumNDCG[k] + dcg / idcg
  }
  nQueries <- nQueries + 1
}

# We first evaluate the top precisions:
precisions <- sumPrecision / nQueries
print("Precisions (@1 - 10):")
print(precisions)

## Next we evaluate the top NDCG:
ndcg <- sumNDCG / nQueries
print("NDCGs (@1 - 10):")
print(ndcg)

