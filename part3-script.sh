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

#!/bin/bash

# 1. Clean compiled classes from the target directory (as you did before)
rm -rf target/*

# 2. Re-define hadoop_classpath (if you opened a new terminal or the variable got unset)
#    Only run these `docker cp` commands if you haven't copied the JARs yet or cleared `hadoop_jars`
#    mkdir -p hadoop_jars # Only if hadoop_jars doesn't exist
#    docker cp master:/opt/hadoop/share/hadoop/common hadoop_jars/common
#    docker cp master:/opt/hadoop/share/hadoop/hdfs hadoop_jars/hdfs
#    docker cp master:/opt/hadoop/share/hadoop/mapreduce hadoop_jars/mapreduce
#    docker cp master:/opt/hadoop/share/hadoop/yarn hadoop_jars/yarn
hadoop_classpath=$(find hadoop_jars -name '*.jar' | tr '\n' ':')
echo "Using classpath: $hadoop_classpath" # This line helps debug if classpath is empty

# 3. Re-compile your Java source code with Java 8 compatibility flags
#    It's good practice to explicitly set -source and -target for compatibility.
javac -source 1.8 -target 1.8 -classpath "$hadoop_classpath" -d target src/main/java/com/yourcompany/hadoop/TransactionCount.java

# 4. VERIFY that .class files were created in the target directory
#    If the 'javac' command above failed, this 'ls' command will show nothing or an error.
ls -l target/com/yourcompany/hadoop/TransactionCount.class

# 5. Create the JAR file
jar -cvf transactioncount.jar -C target .

# 6. VERIFY JAR content (should list the class file)
#    This command will show you what's inside your JAR.
jar -tf transactioncount.jar


# Copy the newly compiled JAR file from your local machine to the master container
docker cp transactioncount.jar master:/tmp/transactioncount.jar

# Now, execute the Hadoop job command inside the master container.
# Make sure to remove any previous output directory to avoid errors.
docker exec -it master /bin/bash -c "hdfs dfs -rm -r /user/hadoop/output_transactions || true && hadoop jar /tmp/transactioncount.jar com.yourcompany.hadoop.TransactionCount /user/hadoop/input /user/hadoop/output_transactions"


# List the contents of the output directory
docker exec -it master /bin/bash -c "hdfs dfs -ls /user/hadoop/output_transactions"

# View the content of the result file (part-r-00000)
docker exec -it master /bin/bash -c "hdfs dfs -cat /user/hadoop/output_transactions/part-r-00000"

