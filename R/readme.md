# Instructions

Make sure you have all the Fold 1 files (train.txt, vali.txt, test.txt) in this working directory.

Since our R program only takes CSV inputs, use libsvm2csv.sh to transform the LibSVM format (default by MSLR-WEB) into CSV format.
```
bash libsvm2csv.sh train.txt > train.csv
bash libsvm2csv.sh test.txt > test.csv
```

Then use genTestSet.sh to prepare the test files (separated based on qid) based on test.csv:
```
bash genTestSet.sh test.csv
```

All the test files are now under the folder called test_csv

The remaining R scripts are self-explanatory.

