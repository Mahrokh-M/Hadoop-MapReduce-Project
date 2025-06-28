#!/bin/bash

hadoop_classpath=$(find hadoop_jars -name '*.jar' | tr '\n' ':')

# Clean previous compiled classes
rm -rf target/*

# Compile the PurchaseStats.java
javac -classpath "$hadoop_classpath" -d target src/main/java/com/yourcompany/hadoop/PurchaseStats.java

# Create the JAR
jar -cvf purchasestats.jar -C target .

# Copy the JAR to the master container
docker cp purchasestats.jar master:/tmp/purchasestats.jar

# Run the Hadoop job inside the container
docker exec -it master hadoop jar /tmp/purchasestats.jar com.yourcompany.hadoop.PurchaseStats /user/hadoop/input /user/hadoop/output_purchasestats

# List output directory
docker exec -it master /bin/bash -c "hdfs dfs -ls /user/hadoop/output_purchasestats"

# Show the results
docker exec -it master /bin/bash -c "hdfs dfs -cat /user/hadoop/output_purchasestats/part-r-00000"
