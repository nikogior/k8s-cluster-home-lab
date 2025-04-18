#!/bin/bash
# Provisioning Pod Network Routes
# Pods scheduled to a node receive an IP address from the node's Pod CIDR range. 
# At this point pods can not communicate with other pods running on different nodes due to missing network routes.
# In this lab you will create a route for each worker node that maps the node's Pod CIDR range to the node's internal IP address.
# There are other ways to implement the Kubernetes networking model.

# The Routing Table
# In this section you will gather the information required to create routes in the kubernetes-the-hard-way VPC network.
# Print the internal IP address and Pod CIDR range for each worker instance:
{
  export SERVER_IP=$(grep controlplane01 machines.txt | cut -d " " -f 1)
  export NODE_0_IP=$(grep node-0 machines.txt | cut -d " " -f 1)
  export NODE_0_SUBNET=$(grep node-0 machines.txt | cut -d " " -f 4)
  export NODE_1_IP=$(grep node-1 machines.txt | cut -d " " -f 1)
  export NODE_1_SUBNET=$(grep node-1 machines.txt | cut -d " " -f 4)
}

ssh root@controlplane01 <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF

ssh root@node-0 <<EOF
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF

ssh root@node-1 <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
EOF

# Verification
ssh root@controlplane01 ip route
# default via XXX.XXX.XXX.XXX dev ens160 
# 10.200.0.0/24 via XXX.XXX.XXX.XXX dev ens160 
# 10.200.1.0/24 via XXX.XXX.XXX.XXX dev ens160 
# XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 

ssh root@node-0 ip route
# default via XXX.XXX.XXX.XXX dev ens160 
# 10.200.1.0/24 via XXX.XXX.XXX.XXX dev ens160 
# XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 

ssh root@node-1 ip route
# default via XXX.XXX.XXX.XXX dev ens160 
# 10.200.0.0/24 via XXX.XXX.XXX.XXX dev ens160 
# XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 