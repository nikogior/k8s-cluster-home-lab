#!/bin/bash
# FROM: https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-jumpbox.md

_remote="jumpbox"
_user="root"
 
echo "Local system name: $HOSTNAME"
echo "Local date and time: $(date)"
 
echo
echo "*** Running commands on remote host named $_remote ***"
echo

# All commands should be executed using the root user under the jumpbox for convenience
# ssh -i ~/.ssh/multipass-ssh-key root@$JUMPBOX_IP 

ssh -T $_remote <<'EOL'
	now="$(date)"
	name="$HOSTNAME"
	up="$(uptime)"
	echo "Server name is $name"
	echo "Server date and time is $now"
	echo "Server uptime: $up"
	echo "Bye"
EOL
