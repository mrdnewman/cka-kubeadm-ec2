
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

# Add the updated Kubernetes repo (change v1.29 if needed)
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

# ===== JOIN LOGIC (choose your poison) =====

# Option A: Join command passed via user_data (manual, not ideal)
# bash /joincommand.sh

# Option B: Use scp to pull join command from master (replace IP + key)
# You’ll need to open port 22 in the master's SG
MASTER_IP="GET MASTER IP"
scp -o StrictHostKeyChecking=no -i /home/ec2-user/your-key.pem ec2-user@${MASTER_IP}:/joincommand.sh /joincommand.sh
chmod +x /joincommand.sh
bash /joincommand.sh

# Option C: Inject the join command via Terraform output and pass it to the worker
# That's cleaner but needs templating or a file provisioner (can help with that too)

