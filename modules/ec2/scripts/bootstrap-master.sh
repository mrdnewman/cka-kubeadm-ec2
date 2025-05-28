
#!/bin/bash
set -e

# Update and install Docker
yum update -y
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

# Disable swap (kubeadm hates swap)
swapoff -a
sed -i '/swap/d' /etc/fstab

# Add updated Kubernetes repo (v1.29 as example)
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

# Initialize the Kubernetes control plane with Flannel pod network CIDR
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Swap

# Setup kubeconfig for ec2-user
mkdir -p /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

# Apply Flannel CNI
sudo -u ec2-user kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Extract join command for worker nodes
kubeadm token create --print-join-command > /joincommand.sh
chmod +x /joincommand.sh

