# Use a minimal OpenJDK 8 image as the base
FROM openjdk:8-jdk-slim

# Set environment variables for Hadoop and Java
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV JAVA_HOME=/usr/local/openjdk-8  
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install necessary packages: SSH server, wget, net-tools, iputils-ping
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    wget \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -xzvf hadoop-$HADOOP_VERSION.tar.gz -C /opt && \
    mv /opt/hadoop-$HADOOP_VERSION $HADOOP_HOME && \
    rm hadoop-$HADOOP_VERSION.tar.gz

# Create necessary directories for NameNode and DataNode data
# These will be mounted as Docker volumes for persistence
RUN mkdir -p /opt/hadoop_data/namenode && \
    mkdir -p /opt/hadoop_data/datanode && \
    mkdir -p $HADOOP_HOME/logs

# Configure SSH for passwordless login (for multi-node communication)
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    chmod 0644 ~/.ssh/id_rsa.pub && \
    chmod 0700 ~/.ssh

# Copy custom configuration files and startup script into the image
# These files are expected to be in a 'config' directory relative to the Dockerfile
COPY config/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/
COPY config/workers $HADOOP_HOME/etc/hadoop/
COPY config/start-hadoop.sh /usr/local/bin/start-hadoop.sh

# Set execute permissions for the startup script
RUN chmod +x /usr/local/bin/start-hadoop.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh

# Expose Hadoop ports
EXPOSE 9870 8088 9000 8020

# Define the command to run when the container starts
# This script will start SSH, format NameNode (if needed), and start Hadoop services
CMD ["/usr/local/bin/start-hadoop.sh"]