#!/bin/bash

# Start SSH service
service ssh start

# Get the current hostname
CURRENT_HOSTNAME=$(hostname)

# Logic for Master Node
if [ "$CURRENT_HOSTNAME" = "master" ]; then
  echo "Running as Master Node: $CURRENT_HOSTNAME"

  # Format NameNode only if the directory is empty (first time setup)
  # This check is crucial to prevent re-formatting on subsequent restarts
  if [[ ! -d "/opt/hadoop_data/namenode/current" ]]; then
    echo "Formatting NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -format -force
  else
    echo "NameNode already formatted. Skipping format."
  fi

  # Start HDFS services (NameNode, DataNodes on workers)
  echo "Starting HDFS services..."
  $HADOOP_HOME/sbin/start-dfs.sh

  # Start YARN services (ResourceManager, NodeManagers on workers)
  echo "Starting YARN services..."
  $HADOOP_HOME/sbin/start-yarn.sh

  echo "Hadoop Master services started."

# Logic for Slave Nodes
else
  echo "Running as Slave Node: $CURRENT_HOSTNAME"
  # Slave nodes only need SSH running and then just stay alive
  echo "Slave node is ready. Waiting for commands from Master."
fi

# Keep the container running indefinitely (for all nodes)
tail -f /dev/null