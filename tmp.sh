


#!/bin/bash
set -euo pipefail

#!/bin/bash
echo "Starting bootstrap for master..." > /tmp/bootstrap.log


REGION="us-west-2"
SECRET_NAME="kubeadmJoinCommand"
USER_HOME="/home/ubuntu"

echo "[BOOTSTRAP] Starting Kubernetes master setup..."

# Update & install dependencies
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common jq awscli gnupg lsb-release

# ---------- Install Docker (Container Runtime) ----------
echo "[BOOTSTRAP] Installing Docker..."

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add ubuntu user to docker group to allow running docker without sudo
usermod -aG docker ubuntu

systemctl enable docker
systemctl start docker

# ---------- Add Kubernetes Repo ----------
echo "[BOOTSTRAP] Adding Kubernetes repo..."

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
  tee /usr/share/keyrings/kubernetes-archive-keyring.gpg >/dev/null

# Original line (broken on some Ubuntu versions)
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | \
  tee /etc/apt/sources.list.d/kubernetes.list

# 🔧 Extra line we added to fix repo download issues:
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | \
  tee -a /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# ---------- Disable Swap ----------
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# ---------- Enable bridged networking ----------
modprobe br_netfilter
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# ---------- kubeadm init ----------
if [ ! -f /etc/kubernetes/admin.conf ]; then
  echo "[BOOTSTRAP] Running kubeadm init..."
  kubeadm init --pod-network-cidr=10.244.0.0/16
else
  echo "[BOOTSTRAP] kubeadm already initialized. Skipping."
fi

# ---------- Configure kubectl for ubuntu user ----------
mkdir -p $USER_HOME/.kube
cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config
chown -R ubuntu:ubuntu $USER_HOME/.kube

# ---------- Deploy Flannel ----------
if ! sudo -u ubuntu kubectl get pods -n kube-system | grep -q kube-flannel; then
  sudo -u ubuntu kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi

# ---------- Generate join command and store in Secrets Manager ----------
JOIN_CMD=$(kubeadm token create --print-join-command)
echo "[BOOTSTRAP] Generated join command: $JOIN_CMD"

aws secretsmanager put-secret-value \
  --secret-id $SECRET_NAME \
  --secret-string "$JOIN_CMD" \
  --region $REGION

echo "[BOOTSTRAP] Kubernetes master setup complete."

