# Set JAVA_HOME
export JAVA_HOME=/usr/local/openjdk-8

# The maximum amount of memory to use for the Java heapsize.
# Units supported by the JVM are also supported here. If no unit is present,
# it will be assumed the number is in megabytes.
# By default, Hadoop will let the JVM determine how much to use.
# This value can be overriden on a per-daemon basis using the appropriate _OPTS variable.
# For example, setting HADOOP_HEAPSIZE_MAX=1g and HADOOP_NAMENODE_OPTS="-Xmx5g"
# will configure the NameNode with 5GB heap.
# export HADOOP_HEAPSIZE_MAX=1024m

# Options for NameNode
# export HDFS_NAMENODE_OPTS="-Xmx2048m"

# Options for DataNode
# export HDFS_DATANODE_OPTS="-Xmx1024m"

# Options for Secondary NameNode
# export HDFS_SECONDARYNAMENODE_OPTS="-Xmx2048m"

# Options for ResourceManager
# export YARN_RESOURCEMANAGER_OPTS="-Xmx1024m"

# Options for NodeManager
# export YARN_NODEMANAGER_OPTS="-Xmx1024m"

# Options for MapReduce JobHistory Server
# export MAPRED_HISTORYSERVER_OPTS="-Xmx1024m"


# Set Hadoop daemon users to root, as the container runs as root
export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"