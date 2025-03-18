#!/bin/bash
# FROM: https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-jumpbox.md

_remote="$JUMPBOX_IP"
_user="root"
 
echo "Local system name: $HOSTNAME"
echo "Local date and time: $(date)"
 
echo
echo "*** Running commands on remote host named $_remote ***"
echo

# All commands should be executed using the root user under the jumpbox for convenience
# ssh -i ~/.ssh/multipass-ssh-key root@$JUMPBOX_IP 

ssh -i ~/.ssh/multipass-ssh-key $_user@$_remote -T <<'EOL'
    now="$(date)"
    name="$HOSTNAME"
    up="$(uptime)"
    echo "Server name is $name"
    echo "Server date and time is $now"
    echo "Server uptime: $up"
    echo "Installing tools..."
    apt-get -y install wget curl vim openssl git
    echo "Tools installed."
    echo "Cloning the Kubernetes the Hard Way repository..."
    if [ -d "kubernetes-the-hard-way" ]; then
        echo "Repository already exists. Pulling latest changes..."
        cd kubernetes-the-hard-way
        git pull
        cd ..
    else
        git clone --depth 1 \
        https://github.com/kelseyhightower/kubernetes-the-hard-way.git 
    fi
    echo "Repository cloned."
    cd kubernetes-the-hard-way
    pwd
    cat downloads.txt

    echo "Replacing arm64 with x86_64 in downloads.txt..."
    sed 's/arm64/x86_64/g' downloads.txt > downloads_x86_64.txt
    mkdir -p downloads

    echo "Downloading binaries into a new directory called 'downloads'..."
    wget -q --show-progress \
    --https-only \
    --timestamping \
    -P downloads \
    -i downloads_x86_64.txt

    ls -loh downloads
    echo "Binaries downloaded."

    echo "Installing kubectl..."
    chmod +x downloads/kubectl
    cp downloads/kubectl /usr/local/bin/   
    echo "kubectl installed."
     
    kubectl version --client
EOL
