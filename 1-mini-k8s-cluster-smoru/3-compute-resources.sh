#!/bin/bash

# Once each key is added, verify SSH public key access is working:
while read IP FQDN HOST SUBNET; do 
  ssh -n root@${IP} uname -o -m
done < machines.txt

# Set the hostname on each machine listed in the machines.txt file:
# (ALREADY SET BY MULTIPASS)
while read IP FQDN HOST SUBNET; do 
    CMD="sed -i 's/^127.0.1.1.*/127.0.1.1\t${FQDN} ${HOST}/' /etc/hosts"
    ssh -n root@${IP} "$CMD"
    ssh -n root@${IP} hostnamectl hostname ${HOST}
done < machines.txt


# Verify the hostname is set on each machine:
while read IP FQDN HOST SUBNET; do
  ssh -n root@${IP} hostname --fqdn
done < machines.txt

# Create a hosts file with the IP and hostname of each machine:
echo "" > hosts
echo "# Kubernetes The Hard Way" >> hosts
while read IP FQDN HOST SUBNET; do 
    ENTRY="${IP} ${FQDN} ${HOST}"
    echo $ENTRY >> hosts
done < machines.txt

cat hosts | sudo tee -a /etc/hosts > /dev/null

# SSH into each machine and verify the hostname is set:
for host in node-0 node-1 controlplane01 jumpbox
   do ssh root@${host} uname -o -m -n
done

# Copy the hosts file to each machine:
while read IP FQDN HOST SUBNET; do
  scp hosts root@${HOST}:~/
  ssh -n \
    root@${HOST} "cat hosts >> /etc/hosts"
done < machines.txt