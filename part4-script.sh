#!/bin/bash
# Ensure the 'target' directory is clean for new compilation
rm -rf target/*

# Compile your Java source code for PurchaseStats
# Re-use the hadoop_classpath from previous step
javac -classpath "$hadoop_classpath" -d target src/main/java/com/yourcompany/hadoop/PurchaseStats.java

# Create the JAR file for PurchaseStats
jar -cvf purchasestats.jar -C target .

# Copy the compiled JAR file from your local machine to the master container
docker cp purchasestats.jar master:/tmp/purchasestats.jar

# Execute the Hadoop job command. Remove previous output directory if it exists.
docker exec -it master /bin/bash -c "hdfs dfs -rm -r /user/hadoop/output_purchasestats || true && hadoop jar /tmp/purchasestats.jar com.yourcompany.hadoop.PurchaseStats /user/hadoop/input /user/hadoop/output_purchasestats"

