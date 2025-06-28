#!/bin/bash
docker exec -it master /bin/bash -c "hdfs dfs -mkdir -p /user/hadoop/input"

# First, copy the CSV file from your local machine into the master Docker container's temporary directory.
docker cp OnlineRetail.csv master:/tmp/OnlineRetail.csv

# Now, execute a command inside the master container to move the file from its local /tmp to HDFS.
docker exec -it master /bin/bash -c "hdfs dfs -put -f /tmp/OnlineRetail.csv /user/hadoop/input/OnlineRetail.csv"

#should see OnlineRetail.csv listed, along with its size and permissions
docker exec -it master /bin/bash -c "hdfs dfs -ls /user/hadoop/input"

