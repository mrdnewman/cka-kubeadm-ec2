#!/bin/bash

# Install Docker
apt-get update && apt-get install -y docker.io

# Install kubelet, kubeadm, kubectl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get update && apt-get install -y kubelet kubeadm kubectl

# Enable and start services
systemctl enable docker
systemctl start docker
