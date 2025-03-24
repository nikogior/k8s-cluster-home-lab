#!/bin/bash
# -- Provisioning a CA and Generating TLS Certificates --
# provision a PKI Infrastructure using openssl to bootstrap a Certificate Authority, 
# and generate TLS certificates for the following components:
# kube-apiserver, kube-controller-manager, kube-scheduler, kubelet, and kube-proxy.
# The commands in this section should be run from the jumpbox.

# ca.conf is already provided by the repo
# The ca.conf file is a template for the OpenSSL configuration file that will be used to generate the CA certificate and private key.

# Generate the CA configuration file, certificate, and private key:
{
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca.conf \
    -out ca.crt
}
# ca.crt ca.key should be created
ls -l ca.*

# generate client and server certificates for each Kubernetes component and a client certificate for the Kubernetes admin user.
certs=(
  "admin"
  "node-0"
  "node-1"
  "kube-proxy"
  "kube-scheduler"
  "kube-controller-manager"
  "kube-api-server"
  "service-accounts"
)
for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "ca.conf" -section ${i} \
    -out "${i}.csr"

  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done

# The results of running the above command will generate a private key, certificate request, and signed SSL certificate for each of the Kubernetes components
ls -l *.crt *.key *.csr

# Distribute the Client and Server Certificates
# Copy the appropriate certificates and private keys to each worker instance:
for host in node-0 node-1; do
  ssh root@$host mkdir /var/lib/kubelet/
  
  scp ca.crt root@$host:/var/lib/kubelet/
    
  scp $host.crt \
    root@$host:/var/lib/kubelet/kubelet.crt
    
  scp $host.key \
    root@$host:/var/lib/kubelet/kubelet.key
done


# Copy the appropriate certificates and private keys to the server machine:
scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@controlplane01:~/
# The kube-proxy, kube-controller-manager, kube-scheduler, and kubelet client certificates will be used to generate client authentication configuration files in the next lab.