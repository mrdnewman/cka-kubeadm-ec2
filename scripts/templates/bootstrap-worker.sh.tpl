
#!/bin/bash
set -e

# Update and install Docker
yum update -y
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

# Disable swap (kubeadm will complain otherwise)
swapoff -a
sed -i '/swap/d' /etc/fstab

# Add the updated Kubernetes repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF

# Install Kubernetes components
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet
systemctl start kubelet

# Join the cluster
kubeadm join ${master_ip}:6443 --token ${join_token} --discovery-token-ca-cert-hash sha256:${ca_cert_hash}

