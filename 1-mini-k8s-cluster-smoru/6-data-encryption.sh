#!/bin/bash
# Kubernetes stores a variety of data including cluster state,
# application configurations, and secrets.
# Kubernetes supports the ability to encrypt cluster data at rest.

# In this lab you will generate an encryption key and 
# an encryption config suitable for encrypting Kubernetes Secrets.

# The Encryption Key
# Generate an encryption key:
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# Create the encryption-config.yaml encryption config file:
envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml

# Copy the encryption-config.yaml encryption config file to each controller instance:
scp encryption-config.yaml root@controlplane01:~/