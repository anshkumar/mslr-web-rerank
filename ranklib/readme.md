# Instructions: How to Use the Scripts

Make sure you have the Fold 1 files (train.txt, vali.txt, test.txt) in this working directory.
Create two folders: models, and ranklib:
```
mkdir models
mkdir ranklib
```
to store the generated models and test results resp.

## Data pre-processing

Use the following command to transform the relevance levels into binary 0 (irrelevant) or 1 (relevant).
We use the criteria from Microsoft: 0 and 1 are categorized as 0, and 2, 3, 4 are categorized as 1.
```
cat test.txt | awk '{if ($1 < 2) printf "0 "; else printf "1 "; \
for (i=2; i<=NF; i++) { printf $i" "; } print "";}' > test_binary.txt
```

## Train and Test
The scripts rerank_train.sh and rerank_test.sh should be self-explanatory.

