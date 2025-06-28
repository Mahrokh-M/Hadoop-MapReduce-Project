#!/bin/bash

# Create a local directory to temporarily store Hadoop JARs for compilation
mkdir -p hadoop_jars

# Copy essential Hadoop JARs from the master container to your local machine
# This only needs to be done once, or if you change Hadoop versions significantly.
docker cp master:/opt/hadoop/share/hadoop/common hadoop_jars/common
docker cp master:/opt/hadoop/share/hadoop/hdfs hadoop_jars/hdfs
docker cp master:/opt/hadoop/share/hadoop/mapreduce hadoop_jars/mapreduce
docker cp master:/opt/hadoop/share/hadoop/yarn hadoop_jars/yarn

# Prepare the classpath for compilation: collect all necessary Hadoop JARs
# For Linux, classpath separator is ':'
hadoop_classpath=$(find hadoop_jars -name '*.jar' | tr '\n' ':')

# Create a 'target' directory for compiled classes
mkdir -p target

# Compile your Java source code
javac -classpath "$hadoop_classpath" -d target src/main/java/com/yourcompany/hadoop/TransactionCount.java

# Create the JAR file
jar -cvf transactioncount.jar -C target .


# Copy the compiled JAR file from your local machine to the master container
docker cp transactioncount.jar master:/tmp/transactioncount.jar

# Now, execute the Hadoop job command inside the master container.
# Make sure to remove any previous output directory to avoid errors.
docker exec -it master /bin/bash -c "hdfs dfs -rm -r /user/hadoop/output_transactions || true && hadoop jar /tmp/transactioncount.jar com.yourcompany.hadoop.TransactionCount /user/hadoop/input /user/hadoop/output_transactions"


# List the contents of the output directory
docker exec -it master /bin/bash -c "hdfs dfs -ls /user/hadoop/output_transactions"

# View the content of the result file (part-r-00000)
docker exec -it master /bin/bash -c "hdfs dfs -cat /user/hadoop/output_transactions/part-r-00000"
