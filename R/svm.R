### Preliminary
library(tidyverse)
library(ROCR)
library(tree)
library(maptree)
library(class)
library(lattice)
library(gbm)
library(e1071)

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

### SVM on binary classification
letor_train_svm <- letor_train_bin
letor_train_svm$rel <- as.factor(letor_train_svm$rel)

## Incredibly time consuming to tune cost parameter using the whole data, instead we tune over a subsample of size 500.
#ind_tune <- sample(nrow(letor_train_svm),500)
#letor_tune <- letor_train_svm[ind_tune,]
#svm.tune <- tune(svm, rel~., data=letor_tune, kernel = "linear", ranges=list(cost=c(0.001, 0.01, 0.1,1,5,10,100)))
#summary(svm.tune)

#### bootstrap training set and use cost=0.001
nBootQueries <- 0
boot_num <- 50
top <- 1:10
svm_boot_prec <- numeric(length(top))
svm_boot_ndcg <- numeric(length(top))
for (i in 1:boot_num) {
  boot_ind <- sample(1:nrow(letor_train_svm), size=nrow(letor_train_svm), replace=T) 
  boot_dat <- letor_train_svm[boot_ind, ]
  boot_svm <- svm(rel~., data=boot_dat, kernel= "linear", cost=0.001,
                  probability=T)
  for (testFile in list.files(path = "test_csv")) {
    letor_test_svm <- read.csv(paste("test_csv", testFile, sep="/"), header = T)
    letor_test_svm_bin <- letor_test_svm %>% mutate(rel = ifelse(rel<2,0,1))
    letor_test_svm_num_labels <- letor_test_svm$rel
    letor_test_svm_num_labels_bin <- letor_test_svm_bin$rel
    letor_test_svm$rel <- as.factor(letor_test_svm$rel)
    letor_test_svm_bin$rel <- as.factor(letor_test_svm_bin$rel)
    boot_pred <- predict(boot_svm, newdata=letor_test_svm, probability=T)
    if (max(letor_test_svm_num_labels) == 0) next;
    for (k in 1:length(top)) {
      ind <- order(attr(boot_pred,"probabilities")[,"1"], decreasing=T)[1:top[k]]
      true_rank <- order(letor_test_svm$rel, decreasing = T)
      svm_boot_prec[k] <- svm_boot_prec[k] + sum(letor_test_svm_num_labels_bin[ind])/top[k]
      dcg <- 0.0
      idcg <- 0.0
      for (i in 1:top[k]) {
        dcg <- dcg + (2^letor_test_svm_num_labels[ind[i]]-1) * log(2.0) / log(i+1)
        idcg <- idcg + (2^letor_test_svm_num_labels[true_rank[i]]-1) * log(2.0) / log(i+1)
      }
      svm_boot_ndcg[k] <- svm_boot_ndcg[k] + dcg / idcg
    }
    nBootQueries <- nBootQueries + 1
  }
}

print("Precisions (@1 - 10):")
print(svm_boot_prec/nBootQueries)

print("NDCGs (@1 - 10):")
print(svm_boot_ndcg/nBootQueries)

