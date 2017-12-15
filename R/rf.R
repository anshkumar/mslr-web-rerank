
library(magrittr)
library(dplyr)
library(randomForest)

# top #
top <- 1:10

### file import
letor <- read.csv("train.csv",header=T)
which(is.na(letor)==TRUE)
table(letor$rel)

### sample training & test set
set.seed(231)
ind <- sample(1:nrow(letor),10000)
letor_train <- letor[ind,]

### Random Forest
letor_rf <- randomForest(as.factor(rel)~., data=letor_train, ntree=500, importance=T)

### Use our new model to predit
nQueries <- 0
sumPrecision <- numeric(length(top))
sumNDCG <- numeric(length(top))
for (testFile in list.files(path = "test_csv")) {
  letor_test <- read.csv(paste("test_csv", testFile, sep="/"), header = T)
  letor_test_bin <- letor_test %>% mutate(rel = ifelse(rel<2,0,1))
  x_test <- model.matrix(~.-rel,data=letor_test_bin)
  letor_pred_prob <- predict(letor_rf, letor_test, type="prob")
  letor_rf_pred <- vector("numeric", length=nrow(letor_test))
  # 5 levels of relevance. 
  for (i in 1:4) {
    letor_rf_pred <- letor_rf_pred + i * letor_pred_prob[,i+1]
  }
  ranking <- order(letor_rf_pred, decreasing = T)[1:max(top)]
  if (letor_test$rel[ranking[1]] == 0) next
  for (k in 1:length(top)) {
    ind <- ranking[1:top[k]]
    precision <- sum(letor_test_bin$rel[ind])/top[k]
    dcg <- 0.0
    for (i in 1:top[k]) {
      dcg <- dcg + (2^letor_test$rel[ind[i]]-1) * log(2.0) / log(i+1)
    }
    idcg <- 0.0
    ind <- order(letor_test$rel, decreasing = T)
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
print("NDCG (@1 - 10):")
print(ndcg)


