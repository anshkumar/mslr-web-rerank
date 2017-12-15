
printf "rel" > $2
for i in $(seq 1 136)
do
  printf ","$i >> $2
done
echo "" >> $2

cat $1 | awk '{printf $1; for(i=3;i<=138;i++){split($i,a,":");printf ","a[2]}print ""}' >> $2

