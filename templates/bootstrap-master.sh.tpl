
#!/bin/bash
set -e

yum update -y
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

swapoff -a
sed -i '/swap/d' /etc/fstab

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet
systemctl start kubelet

kubeadm init --pod-network-cidr=10.244.0.0/16

kubeadm token create --print-join-command > /joincommand.sh
chmod +x /joincommand.sh

# (Optional) setup kubeconfig for ec2-user here

# Allow SSH from workers (adjust your SG to allow this)

