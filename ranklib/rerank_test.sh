
for n in $(seq 1 10)
do
  echo "mart: "$n
  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_mart.txt -test test.txt   \
       -metric2T "NDCG@"$n \
       > "ranklib/10k_mart_ndcg"$n".txt"

  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_mart.txt -test test_binary.txt   \
       -metric2T "P@"$n \
       > "ranklib/10k_mart_p"$n".txt"
done

for n in $(seq 1 10)
do
  echo "ranknet: "$n
  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_ranknet.txt -test test.txt   \
       -metric2T "NDCG@"$n \
       > "ranklib/10k_ranknet_ndcg"$n".txt"

  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_ranknet.txt -test test_binary.txt   \
       -metric2T "P@"$n \
       > "ranklib/10k_ranknet_p"$n".txt"
done

for n in $(seq 1 10)
do
  echo "rankboost: "$n
  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_rankboost.txt -test test.txt   \
       -metric2T "NDCG@"$n \
       > "ranklib/10k_rankboost_ndcg"$n".txt"

  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_rankboost.txt -test test_binary.txt   \
       -metric2T "P@"$n \
       > "ranklib/10k_rankboost_p"$n".txt"
done

for n in $(seq 1 10)
do
  echo "adarank: "$n
  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_adarank.txt -test test.txt   \
       -metric2T "NDCG@"$n \
       > "ranklib/10k_adarank_ndcg"$n".txt"

  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_adarank.txt -test test_binary.txt   \
       -metric2T "P@"$n \
       > "ranklib/10k_adarank_p"$n".txt"
done

for n in $(seq 1 10)
do
  echo "ca: "$n
  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_ca.txt -test test.txt   \
       -metric2T "NDCG@"$n \
       > "ranklib/10k_ca_ndcg"$n".txt"

  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_ca.txt -test test_binary.txt   \
       -metric2T "P@"$n \
       > "ranklib/10k_ca_p"$n".txt"
done

for n in $(seq 1 10)
do
  echo "lambda: "$n
  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_lambda.txt -test test.txt   \
       -metric2T "NDCG@"$n \
       > "ranklib/10k_lambda_ndcg"$n".txt"

  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_lambda.txt -test test_binary.txt   \
       -metric2T "P@"$n \
       > "ranklib/10k_lambda_p"$n".txt"
done

for n in $(seq 1 10)
do
  echo "listnet: "$n
  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_listnet.txt -test test.txt   \
       -metric2T "NDCG@"$n \
       > "ranklib/10k_listnet_ndcg"$n".txt"

  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_listnet.txt -test test_binary.txt   \
       -metric2T "P@"$n \
       > "ranklib/10k_listnet_p"$n".txt"
done

for n in $(seq 1 10)
do
  echo "rf: "$n
  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_rf.txt -test test.txt   \
       -metric2T "NDCG@"$n \
       > "ranklib/10k_rf_ndcg"$n".txt"

  java -Xmx12000m -jar ./RankLib-2.5.jar  \
       -load models/model_rf.txt -test test_binary.txt   \
       -metric2T "P@"$n \
       > "ranklib/10k_rf_p"$n".txt"
done

