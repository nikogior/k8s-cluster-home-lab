#!/bin/bash
# We need the following nodes deployed:
# (1 master, 2 workers):
# Name                                       CPUs   Memory  Disk
# jumpbox	        Administration host	        1	512MB	10GB
# controlplane01	Kubernetes server	        1	2GB	    20GB
# node-0	        Kubernetes worker node	    1	2GB	    20GB
# node-1	        Kubernetes worker node	    1	2GB	    20GB
PWD=$(pwd)

# Deploy the nodes
multipass launch --name jumpbox --cpus 1 --memory 512M --disk 10G
multipass launch --name controlplane01 --cpus 1 --memory 2G --disk 20G
multipass launch --name node-0 --cpus 1 --memory 2G --disk 20G
multipass launch --name node-1 --cpus 1 --memory 2G --disk 20G

# List nodes and resources used:
multipass list
multipass info jumpbox
multipass info controlplane01
multipass info node-0
multipass info node-1

# Save the IP addresses of the nodes
if multipass list | grep -q jumpbox; then
    export JUMPBOX_IP=$(multipass info jumpbox --format json | jq -r '.info[].ipv4[0]')
    alias jumpbox="ssh -i ~/.ssh/multipass-ssh-key root@$JUMPBOX_IP"

fi

if multipass list | grep -q controlplane01; then
    export CONTROLPLANE01_IP=$(multipass info controlplane01 --format json | jq -r '.info[].ipv4[0]')
    alias controlplane01="ssh -i ~/.ssh/multipass-ssh-key root@$CONTROLPLANE01_IP"

fi

if multipass list | grep -q node-0; then
    export NODE0_IP=$(multipass info node-0 --format json | jq -r '.info[].ipv4[0]')
    alias node01="ssh -i ~/.ssh/multipass-ssh-key root@$NODE0_IP"

fi

if multipass list | grep -q node-1; then
    export NODE1_IP=$(multipass info node-1 --format json | jq -r '.info[].ipv4[0]')
    alias node02="ssh -i ~/.ssh/multipass-ssh-key root@$NODE1_IP"
fi


# export JUMPBOX_IP=$(multipass info jumpbox --format json | jq -r '.info[].ipv4[0]')
# export CONTROLPLANE01_IP=$(multipass info controlplane01 --format json | jq -r '.info[].ipv4[0]')
# export NODE0_IP=$(multipass info node-0 --format json | jq -r '.info[].ipv4[0]')
# export NODE1_IP=$(multipass info node-1 --format json | jq -r '.info[].ipv4[0]')

echo "Jumpbox IP: $JUMPBOX_IP"
echo "Controlplane01 IP: $CONTROLPLANE01_IP"
echo "Node-0 IP: $NODE0_IP"
echo "Node-1 IP: $NODE1_IP"

# Ensure you setup authentication with mulitpass
# multipass set local.passphrase
# multipass authenticate
# cat ~/snap/multipass/current/data/multipass-client-certificate/multipass_cert.pem | sudo tee -a /var/snap/multipass/common/data/multipassd/authenticated-certs/multipass_client_certs.pem > /dev/null
# snap restart multipass

# Setup SSH keys
cd ~/.ssh
ssh-keygen -C vmuser -f multipass-ssh-key -q -N ""
# multipass transfer ~/.ssh/multipass-ssh-key.pub jumpbox:~/.ssh/multipass-ssh-key.pub
cat  ~/.ssh/multipass-ssh-key.pub | multipass transfer - jumpbox:.ssh/multipass-ssh-key.pub
cat  ~/.ssh/multipass-ssh-key.pub | multipass transfer - controlplane01:.ssh/multipass-ssh-key.pub
cat  ~/.ssh/multipass-ssh-key.pub | multipass transfer - node-0:.ssh/multipass-ssh-key.pub
cat  ~/.ssh/multipass-ssh-key.pub | multipass transfer - node-1:.ssh/multipass-ssh-key.pub


# Add the key in every node under the root user:
multipass exec jumpbox -- bash -c "sudo cat ~/.ssh/multipass-ssh-key.pub  | sudo tee -a /root/.ssh/authorized_keys"
multipass exec controlplane01 -- bash -c "sudo cat ~/.ssh/multipass-ssh-key.pub  | sudo tee -a /root/.ssh/authorized_keys"
multipass exec node-0 -- bash -c "sudo cat ~/.ssh/multipass-ssh-key.pub  | sudo tee -a /root/.ssh/authorized_keys"
multipass exec node-1 -- bash -c "sudo cat ~/.ssh/multipass-ssh-key.pub  | sudo tee -a /root/.ssh/authorized_keys"

# Change the permissions of the .ssh folder and the authorized_keys file
multipass exec jumpbox -- bash -c "sudo chmod 700 /root/.ssh"
multipass exec jumpbox -- bash -c "sudo chmod 600 /root/.ssh/authorized_keys"
multipass exec controlplane01 -- bash -c "sudo chmod 700 /root/.ssh"
multipass exec controlplane01 -- bash -c "sudo chmod 600 /root/.ssh/authorized_keys"
multipass exec node-0 -- bash -c "sudo chmod 700 /root/.ssh"
multipass exec node-0 -- bash -c "sudo chmod 600 /root/.ssh/authorized_keys"
multipass exec node-1 -- bash -c "sudo chmod 700 /root/.ssh"
multipass exec node-1 -- bash -c "sudo chmod 600 /root/.ssh/authorized_keys"

# Connecting into every instance:
alias jumpbox="ssh -i ~/.ssh/multipass-ssh-key root@$JUMPBOX_IP"
alias controlplane01="ssh -i ~/.ssh/multipass-ssh-key root@$CONTROLPLANE01_IP"
alias node01="ssh -i ~/.ssh/multipass-ssh-key root@$NODE0_IP"
alias node02="ssh -i ~/.ssh/multipass-ssh-key root@$NODE1_IP"


# ---------------------------------------------------------------------------------------------------------------------
# # Another way to add the public key to the nodes while they are being created:
# cd $PWD
# PUB_KEY=$(cat ~/.ssh/multipass-ssh-key.pub)
# touch cloud-init.yaml
# # Add the following content to cloud-init.yaml
# cat <<EOF > cloud-init.yaml
# users:
#     - default
#     - name: vmuser
#         sudo: ALL=(ALL) NOPASSWD:ALL
#         ssh_authorized_keys:
#         - PUB_KEY # Add the content of the public key here
# EOF
# sed -i -e "s/PUB_KEY/$PUB_KEY/g" cloud-init.yaml
# multipass launch -n testvm --cloud-init cloud-init.yaml

# multipass exec jumpbox -- bash -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
# multipass exec controlplane01 -- bash -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
# multipass exec node-0 -- bash -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"
# multipass exec node-1 -- bash -c "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa"

# # Copy SSH keys to the nodes
# multipass exec jumpbox -- bash -c "ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$CONTROLPLANE01_IP"
# multipass exec jumpbox -- bash -c "ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$NODE0_IP"
# multipass exec jumpbox -- bash -c "ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$NODE1_IP"

# # Copy SSH keys to the nodes
# multipass exec controlplane01 -- bash -c "ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$JUMPBOX_IP"
# multipass exec controlplane01 -- bash -c "ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$NODE0_IP"
# multipass exec controlplane01 -- bash -c "ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$NODE1_IP"
