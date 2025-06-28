#!/bin/bash
# Remove the old scaled file if it exists, to ensure a fresh 10x copy
rm -f OnlineRetail_10x.csv

# Create a 10x scaled version of OnlineRetail.csv by appending it 9 more times
# (The first `cat` copies it once, then the loop appends 9 more times)
cat OnlineRetail.csv > OnlineRetail_10x.csv
for i in $(seq 1 9); do cat OnlineRetail.csv >> OnlineRetail_10x.csv; done

# (Optional) Verify the new file size (it should be roughly 10x larger)
ls -lh OnlineRetail_10x.csv

# Remove the old input directory in HDFS and the temporary file in master container
docker exec -it master /bin/bash -c "hdfs dfs -rm -r /user/hadoop/input_10x || true"
docker exec -it master /bin/bash -c "rm -f /tmp/OnlineRetail_10x.csv || true"

# Copy the scaled CSV to the master container
docker cp OnlineRetail_10x.csv master:/tmp/OnlineRetail_10x.csv

# Create a new HDFS input directory for the scaled data
docker exec -it master /bin/bash -c "hdfs dfs -mkdir -p /user/hadoop/input_10x"

# Upload the scaled CSV to the new HDFS input directory
docker exec -it master /bin/bash -c "hdfs dfs -put -f /tmp/OnlineRetail_10x.csv /user/hadoop/input_10x/OnlineRetail_10x.csv"

# Run the TransactionCount job using the scaled data 
docker exec -it master /bin/bash -c "hdfs dfs -rm -r /user/hadoop/output_transactions_10x || true && hadoop jar /tmp/transactioncount.jar com.yourcompany.hadoop.TransactionCount /user/hadoop/input_10x /user/hadoop/output_transactions_10x"


# This command should be copy-pasted as one single line.
docker exec -it master /bin/bash -c "hdfs dfs -rm -r /user/hadoop/output_transactions_tuned || true && hadoop jar /tmp/transactioncount.jar com.yourcompany.hadoop.TransactionCount /user/hadoop/input_10x /user/hadoop/output_transactions_tuned -Dmapreduce.job.reduces=4"
