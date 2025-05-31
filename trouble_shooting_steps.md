
# 🛠️ Kubeadm Cluster Infra + Troubleshooting Cheat Sheet

A no-fluff cheat sheet based on real-world cluster builds using `kubeadm`, Terraform, and AWS.

---

## 🔧 INFRASTRUCTURE SETUP OVERVIEW

**Tools Used:**

- **Terraform** – Provisions EC2 master + workers, VPC, key pair, etc.
- **AWS Secrets Manager** – Shares `kubeadm join` command between nodes
- **User Data Scripts** – Bootstrap scripts at EC2 instance launch
- **Ubuntu 22.04 LTS** – Base image for all nodes

---

## 💣 COMMON ISSUES + ROOT CAUSES + FIXES

### ✅ Master Node Bootstrap

**Issue:**
`kubeadm init` fails with `Port 6443 is in use`

**Cause:**
You re-ran the master bootstrap script on an existing node without cleaning it up.

**Fix:**

**Option 1:**

terraform destroy -auto-approve

---

Option 2: Manual cleanup:

sudo kubeadm reset -f
sudo systemctl stop kubelet
sudo rm -rf /etc/kubernetes /var/lib/etcd ~/.kube

---

🧵 Worker Node Won't Join (Stuck on pre-flight)
Symptoms:

- Join fails or hangs
- kubectl get nodes shows nothing
- kubeadm join output is silent or errors on networking

🔍 Problem			🧠 Why						✅ Fix
ip_forward != 1			Required for pod networking			Add net.ipv4.ip_forward=1 to /etc/sysctl.conf + run sysctl -p
Join command missing		Master hasn't pushed to Secrets Manager yet	Add retry loop in worker bootstrap (see below)
Worker starts too fast		Master not ready with join command		Add sleep 100 at top of worker script
No container runtime		kubelet can't launch pods			Set KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/containerd.sock

---

🔁 Secrets Manager Join Retry Loop (Worker Script)

# Wait for master to publish join command
until aws secretsmanager get-secret-value --secret-id /k8s/joincommand --query SecretString --output text | grep -q 'kubeadm join'; do
  echo "[WAIT] Join command not ready. Retrying in 15s..."
  sleep 15
done

JOIN_CMD=$(aws secretsmanager get-secret-value --secret-id /k8s/joincommand --query SecretString --output text)
eval $JOIN_CMD

---

🧨 Kubelet Failed to Start

🔍 Symptoms
- kubeadm hangs or fails during init/join
- journalctl -u kubelet shows repeated errors
- Node doesn’t appear in kubectl get nodes

sudo apt install -y containerd
sudo systemctl enable --now containerd
|
| ❌ Missing kubelet config | kubelet needs `/etc/kubernetes/kubelet.conf` | Normal pre-init/join – ignore unless it persists |
| ❌ No runtime endpoint specified | kubelet can’t find container runtime |  

echo 'KUBELET_EXTRA_ARGS=--container-runtime-endpoint=unix:///run/containerd/containerd.sock' | sudo tee /etc/default/kubelet
sudo systemctl daemon-reexec
sudo systemctl restart kubelet
``` |
| ❌ Swap is enabled | kubelet refuses to start with swap on |  

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
|
| ❌ IP forwarding off | Required for pod + kube-proxy networking |  
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sudo sysctl -p
``` |

---

## 🧪 Diagnosing the Kubelet


# Check kubelet logs
journalctl -xeu kubelet

# Service status
systemctl status kubelet

# Reload and restart
systemctl daemon-reexec
systemctl restart kubelet

⚙️ kubeadm Preflight Check (Dry Run)
kubeadm join <your command> --dry-run --v=5

---

🐢 Worker Node Slow to Join?
Symptom:
Worker runs bootstrap but never shows in kubectl get nodes.

Fix:
Add a delay to wait for master to finish:

---

FINAL Pro Tips

- Don't hardcode IPs in join commands – use Secrets Manager.
- Always reset before retrying kubeadm init/join.
- Use --v=5 with kubeadm for debugging.

Confirm node readiness with:
kubectl get nodes

