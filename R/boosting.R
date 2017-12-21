###################################
##### PSTAT 231 Final Project #####
##        Author: Sen LEI        ##
###################################




##### Pre-Setting #####

library(plyr)
library(tidyverse)
library(tree)
library(randomForest)
library(class)
library(rpart)
library(rpart.plot)
library(maptree)
library(ROCR)
library(MASS)
library(e1071)


##### DATA lector #####
lector <- read.csv("train.csv", header = T)

# Data Modification 
lector$rel <- as.ordered(lector$rel)


set.seed(231)
test_index <- sample(1:dim(lector)[1], 10000, replace=T)
lector_train <- lector[test_index, ]
#lector_train <- lector[,]

## Assign the Data Set that we are using
train_samp <- lector_train

library(caret)
library(gbm)
#gbm_grid <- expand.grid(.interaction.depth = (1:3)*2,
#                        .n.trees = (4:12)*250, .shrinkage = 0.001, .n.minobsinnode = 10)
set.seed(231)
#gbm_tune <- caret::train(train_samp[,2:137], train_samp[,1], method = "gbm", 
#                         trControl = trainControl(number=100), verbose = F, 
#                         bag.fraction = 0.5, tuneGrid = gbm_grid)
## after tuning we have best.size & best.depth 
gbm_letor <- gbm(rel~., data=train_samp, distribution = "multinomial", 
                 n.trees = 1250, interaction.depth = 4)

summary(gbm_letor)

## test
top <- 1:10
nQueries <- 0
sumPrecision <- numeric(length(top))
sumNDCG <- numeric(length(top))
for (testFile in list.files(path = "test_csv")) {
  letor_test <- read.csv(paste("test_csv", testFile, sep="/"), header = T)
  X_test <- letor_test[, 2:dim(letor_test)[2]]
  #pred <- predict(Tree_pruned, X_test, type = "class")
  pred <- predict(gbm_letor, X_test, n.trees = 1250, type = "response")

  pred_rank <-  pred[,,1]
  pred_exp <- pred_rank[,2] + pred_rank[,3]*2 + pred_rank[,4]*3 + pred_rank[,5]*4
  rank <- order(pred_exp, decreasing=T)
  rel_new <- ifelse(letor_test$rel<=1, 0, 1) 
  ind <- order(letor_test$rel, decreasing = T)
  if (letor_test$rel[ind[1]] == 0) next
  for (k in 1:length(top)) {
    precision <- sum(rel_new[rank[1:top[k]]])/top[k]
    dcg <- 0.0
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


