#!/usr/bin/bash

# $1 = path/to/test.txt
# assume libsvm2csv.sh is in the working directory

mkdir ./test
mkdir ./test_csv

for qid in $(cat $1 | awk '{print $2}' | sort | uniq -c | awk '{if($1>=10) print $2}'); do grep " "$qid" " /mnt/ssd2/shiyu/Fold1/test.txt > "test/fold1"$qid".txt"; done

cd test
for f in ./*; do bash ../libsvm2csv.sh $f $f".csv"; done
mv *.csv ../test_csv
cd ..

