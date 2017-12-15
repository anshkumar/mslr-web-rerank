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


##### DATA lector #####
lector <- read.csv("train.csv", header = T)

# Data Modification 
lector$rel <- as.ordered(lector$rel)


set.seed(231)
test_index <- sample(1:dim(lector)[1], 10000)
lector_train <- lector[test_index, ]
#lector_train <- lector[,]

## Assign the Data Set that we are using
dt <- lector_train




##### Decision Tree #####

num_train <- dim(dt)[1]
mincut <- 5 # The minimum number of observations to include in either child node.
minsize <- 10 # The smallest allowed node size: a weighted quantity.
mindev <- 1*10^(-5) # The within-node deviance must be at least this times that of the root node for the node to be split.

tree_control <- tree.control(num_train, mincut=mincut, minsize=minsize, mindev=mindev)
rm(num_train, mincut, minsize, mindev)


dt$rel <- as.factor(dt$rel)
str(dt$rel)

Tree <- tree(formula=rel~., data=lector_train, control=tree_control)
summary(Tree)


Tree_pruned <- prune.tree(Tree, best=10)
draw.tree(Tree_pruned, nodeinfo=TRUE)

#####
Listen.tree.prune <- function(tree, rand, k=10){ # method="misclass"
  tree_cv <- cv.tree(tree, rand, K=k, method="misclass")
  
  outcome <- data.frame(nodes = tree_cv$size, dev=tree_cv$dev, k=tree_cv$k)
  id <- seq.int(dim(outcome)[1])
  outcome <- data.frame(cbind(id, outcome))
  outcome_2 <- outcome[outcome$dev==min(outcome$dev),]
  outcome_3 <- outcome_2[which.min(outcome_2$nodes),]
  
  plot <- ggplot(outcome, aes(x=nodes, y=dev)) + 
    geom_point() + 
    geom_point(aes(x=nodes[outcome_3$id], y=dev[outcome_3$id]), 
               colour="red", shape=8, size=3)
  print(plot)
  
  cat("The CV test error is minimized when the mumber of nodes equals", 
      outcome_3[which.min(outcome_3$nodes), "nodes"], "\n")
  
  result <- list("all"=outcome_2, "best"=outcome_3)
  return(result)
}
#####


## 5-fold cross-validation ##
# Using dt = lector_train data
chunk_num <- 10
chunk_id <- cut(seq.int(nrow(dt)), breaks=chunk_num, labels=FALSE) ## sequential fold ids
set.seed(1)
chunk_id_rand <- sample(chunk_id)
rm(chunk_id)

tree_cv <- Listen.tree.prune(tree=Tree, rand=chunk_id_rand, k=10)

Tree_pruned <- prune.tree(Tree, best=2) # final (tree) model
draw.tree(Tree_pruned, nodeinfo=TRUE)

## test
top <- 1:10
nQueries <- 0
sumPrecision <- numeric(length(top))
sumNDCG <- numeric(length(top))
for (testFile in list.files(path = "test_csv")) {
  letor_test <- read.csv(paste("test_csv", testFile, sep="/"), header = T)
  if (max(letor_test$rel) == 0) next
  X_test <- letor_test[, 2:dim(letor_test)[2]]
  pred <- predict(Tree_pruned, X_test, type = "class")

  pred_exp <-  pred
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


