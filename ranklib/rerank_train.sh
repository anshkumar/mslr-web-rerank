
java -Xmx32000m -jar ./RankLib-2.5.jar -silent -ranker 0 -train train.txt -validate vali.txt -metric2t MAP -save "models/model_mart.txt" &
java -Xmx32000m -jar ./RankLib-2.5.jar -silent -ranker 1 -train train.txt -validate vali.txt -metric2t MAP -save "models/model_ranknet.txt" &
java -Xmx32000m -jar ./RankLib-2.5.jar -silent -ranker 2 -train train.txt -validate vali.txt -metric2t MAP -save "models/model_rankboost.txt" &
java -Xmx32000m -jar ./RankLib-2.5.jar -silent -ranker 3 -train train.txt -validate vali.txt -metric2t MAP -save "models/model_adarank.txt" &
java -Xmx32000m -jar ./RankLib-2.5.jar -silent -ranker 4 -train train.txt -validate vali.txt -metric2t MAP -save "models/model_ca.txt" &
java -Xmx32000m -jar ./RankLib-2.5.jar -silent -ranker 6 -train train.txt -validate vali.txt -metric2t MAP -save "models/model_lambda.txt" &
java -Xmx32000m -jar ./RankLib-2.5.jar -silent -ranker 7 -train train.txt -validate vali.txt -metric2t MAP -save "models/model_listnet.txt" &
java -Xmx32000m -jar ./RankLib-2.5.jar -silent -ranker 8 -train train.txt -validate vali.txt -metric2t MAP -save "models/model_rf.txt" &


