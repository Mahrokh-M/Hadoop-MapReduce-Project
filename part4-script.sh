#!/bin/bash

# Ensure the 'target' directory is clean for new compilation
rm -rf target/*

# Compile your Java source code for PurchaseStats
# Re-use the hadoop_classpath from previous step
javac -classpath "$hadoop_classpath" -d target src/main/java/com/yourcompany/hadoop/PurchaseStats.java

# Create the JAR file for PurchaseStats
jar -cvf purchasestats.jar -C target .


# List the contents of the output directory
docker exec -it master /bin/bash -c "hdfs dfs -ls /user/hadoop/output_purchasestats"

# View the content of the result file (part-r-00000)
docker exec -it master /bin/bash -c "hdfs dfs -cat /user/hadoop/output_purchasestats/part-r-00000"
