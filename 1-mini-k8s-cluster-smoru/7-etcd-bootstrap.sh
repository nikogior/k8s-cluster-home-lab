#!/bin/bash

# Kubernetes components are stateless and store cluster state in etcd. 
# In this lab you will bootstrap a three node etcd cluster and 
# configure it for high availability and secure remote access.

# Ensure you use the right downloads:
{
    echo "Repository cloned."
    cd kubernetes-the-hard-way
    pwd
    cat downloads.txt

    echo "Replacing arm64 with amd64 in downloads.txt..."
    sed 's/arm64/amd64/g' downloads.txt > downloads_amd64.txt
    mkdir -p downloads

    echo "Downloading binaries into a new directory called 'downloads'..."
    wget -q --show-progress \
    --https-only \
    --timestamping \
    -P downloads \
    -i downloads_amd64.txt

    ls -loh downloads
    echo "Binaries downloaded."
}

# Copy etcd binaries and systemd unit files to the server instance:
scp \
  downloads/etcd-v3.4.34-linux-amd64.tar.gz \
  units/etcd.service \
  root@controlplane01:~/

# --------------------------------------------------------------------------------------------
# The commands in this lab must be run on the server machine. Login to the server machine using the ssh command. Example:
ssh root@controlplane01

# Bootstrapping an etcd Cluster

# Install the etcd Binaries
# Extract and install the etcd server and the etcdctl command line utility:
{
  tar -xvf etcd-v3.4.34-linux-amd64.tar.gz
  mv etcd-v3.4.34-linux-amd64/etcd* /usr/local/bin/
}
# Configure the etcd Server
{
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp ca.crt kube-api-server.key kube-api-server.crt \
    /etc/etcd/
}

# Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:
# Create the etcd.service systemd unit file:
mv etcd.service /etc/systemd/system/
# Start the etcd Server
{
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd
}


# Verification
# List the etcd cluster members:
etcdctl member list
# 6702b0a34e2cfd39, started, controller, http://127.0.0.1:2380, http://127.0.0.1:2379, false