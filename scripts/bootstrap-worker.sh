#!/bin/bash
set -euo pipefail

REGION="us-west-2"
SECRET_NAME="kubeadmJoinCommand"
USER_HOME="/home/ubuntu"

sleep 100

echo "[BOOTSTRAP] Starting Kubernetes worker setup..."

# ---------- Update & install dependencies ----------
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common jq awscli gnupg lsb-release

# ---------- Install containerd ----------
echo "[BOOTSTRAP] Installing containerd..."
install -m 0755 -d /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor > /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y containerd

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# Configure containerd and restart
systemctl restart containerd
systemctl enable containerd

# ---------- Add Kubernetes apt repo (overwrite-safe) ----------
echo "[BOOTSTRAP] Adding Kubernetes apt repository..."
rm -f /usr/share/keyrings/kubernetes-archive-keyring.gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
  | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
| tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
ln -sf /usr/bin/kubectl /usr/local/bin/kubectl

# ---------- Disable swap ----------
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# ---------- Enable bridged networking for iptables ----------
modprobe br_netfilter
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

# ---------- Stop kubelet early to avoid startup errors ----------
systemctl stop kubelet || true

# ---------- Tell kubelet to use containerd ----------
echo "[BOOTSTRAP] Configuring kubelet to use containerd..."
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/containerd.sock
EOF

# ---------- Restart kubelet after all dependencies configured ----------
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart kubelet
systemctl enable kubelet

echo "[BOOTSTRAP] Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

echo "[BOOTSTRAP] Waiting 15s to ensure system is ready..."
sleep 15

# ---------- Retrieve join command from AWS Secrets Manager ----------
echo "[BOOTSTRAP] Retrieving join command from AWS Secrets Manager..."
JOIN_CMD=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$REGION" \
  --query SecretString \
  --output text)

if [[ -z "$JOIN_CMD" ]]; then
  echo "[ERROR] Retrieved kubeadm join command is empty. Exiting."
  exit 1
fi

# ---------- Execute kubeadm join ----------
MAX_RETRIES=5
for i in $(seq 1 $MAX_RETRIES); do
  echo "[BOOTSTRAP] Attempt $i to join cluster..."
  bash -c "$JOIN_CMD" && break
  sleep 10
done


echo "[BOOTSTRAP] Kubernetes worker node joined successfully."
