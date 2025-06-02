#!/bin/bash
set -euo pipefail

REGION="us-west-2"
SECRET_NAME="kubeadmJoinCommand"
USER_HOME="/home/ubuntu"

echo "[BOOTSTRAP] Starting Kubernetes master setup..."

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

# ── Force containerd to use systemd cgroups ────────────────────────────────
sudo sed -i 's/^\s*SystemdCgroup = .*/        SystemdCgroup = true/' /etc/containerd/config.toml
# ──────────────────────────────────────────────────────────────────────────

sudo systemctl restart containerd
sudo systemctl enable containerd

# ---------- Add Kubernetes apt repo (overwrite-safe) ----------
echo "[BOOTSTRAP] Adding Kubernetes apt repository..."
rm -f /usr/share/keyrings/kubernetes-archive-keyring.gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
  | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
| sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo ln -sf /usr/bin/kubectl /usr/local/bin/kubectl

# ── Enable kubelet service ─────────────────────────────────────────────────
sudo systemctl enable kubelet
# ────────────────────────────────────────────────────────────────────────────

# ---------- Disable swap ----------
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# ---------- Enable bridged networking & IP forwarding ───────────────────────
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
EOF
sudo sysctl --system

# ---------- Configure kubelet to use containerd ----------
echo "[BOOTSTRAP] Configuring kubelet to use containerd..."
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/containerd.sock
EOF


sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# ---------- Initialize Kubernetes master ----------

cat <<EOF > /tmp/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
clusterName: ${cluster_name}
kubernetesVersion: stable
networking:
  podSubnet: 10.244.0.0/16
EOF

if [ ! -f /etc/kubernetes/admin.conf ]; then
  echo "[BOOTSTRAP] Running kubeadm init..."
  sudo kubeadm init --config=/tmp/kubeadm-config.yaml --cri-socket=unix:///run/containerd/containerd.sock
else
  echo "[BOOTSTRAP] kubeadm already initialized. Skipping."
fi

# ---------- Configure kubeconfig for ubuntu user ----------
sudo chown ubuntu:ubuntu /etc/kubernetes/admin.conf
mkdir -p /home/ubuntu/.kube
sudo cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube

# ---------- Deploy Flannel CNI if not present ----------
if ! sudo -u ubuntu kubectl get pods -n kube-system | grep -q kube-flannel; then
  sudo -u ubuntu kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi

# ---------- Generate & store join command in AWS Secrets Manager ----------
JOIN_CMD=$(sudo kubeadm token create --print-join-command)
echo "[BOOTSTRAP] Generated join command: $JOIN_CMD"

aws secretsmanager put-secret-value \
  --secret-id "$SECRET_NAME" \
  --secret-string "$JOIN_CMD" \
  --region "$REGION"

echo "[BOOTSTRAP] Updated Secrets Manager secret '$SECRET_NAME' with join command."
echo "[BOOTSTRAP] Kubernetes master setup complete."
