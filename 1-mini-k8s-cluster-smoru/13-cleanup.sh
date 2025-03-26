#!/bin/bash
# Cleaning Up
# In this lab you will delete the compute resources created during this tutorial.

# Compute Instances
# Previous versions of this guide made use of GCP resources for various aspects of compute and networking. The current version is agnostic, and all configuration is performed on the jumpbox, server, or nodes.

# Clean up is as simple as deleting all virtual machines you created for this exercise.
multipass delete jumpbox
multipass delete controlplane01
multipass delete node-0
multipass delete node-1
