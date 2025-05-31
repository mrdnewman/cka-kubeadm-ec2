
<h1 align="center" style="color:#2E86C1;"><b>☁️ Bare Metal Kubernetes with Terraform + kubeadm + AWS Secrets Manager</b></h1>

<p align="center">
  <i>Deploy a fully functioning Kubernetes cluster using **Ubuntu 22.04**, **Terraform**, and **kubeadm** — no EKS, no shortcuts. Built for hands-on DevOps learning with full control of the control plane.</i>
</p>

---

## 🧰 What This Project Does

- 🏗️ Provisions AWS EC2 instances via Terraform (1 master, N workers)
- 🔐 Generates and stores the kubeadm `join` command securely in **AWS Secrets Manager**
- 🤖 Automatically bootstraps control plane and joins workers using custom bash scripts
- 🐳 Uses **containerd** as the container runtime
- 🔧 Installs **Flannel CNI** for pod networking
- 💡 Uses a loop logic on workers to *wait* for the join command to appear

---

<h2 style="color:#F4D03F;"><b>⚙️ What’s Under the Hood</b></h2>

<ul>
  <li><b>Terraform Modules:</b> VPC, Security Groups, Key Pair, Master and Worker EC2 instances</li>
  <li><b>Bash Bootstrap Scripts:</b> Fully automated for both Master and Worker nodes</li>
  <li><b>Cloud-Integrated:</b> <a href="https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html" style="color:#1F618D;"><b>AWS Secrets Manager</b></a> delivers the join command securely</li>
  <li><b>Cluster Bootstrapping:</b> <a href="https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/" style="color:#1F618D;"><b>kubeadm</b></a> used for robust, declarative control-plane setup</li>
  <li><b>CNI:</b> <a href="https://github.com/flannel-io/flannel" style="color:#1F618D;"><b>Flannel</b></a> networking configured on Master</li>
</ul>

---

<h2 style="color:#5DADE2;"><b>🚀 Achievements / Résumé Bullets</b></h2>

<ul>
  <li>Built a dynamic Kubernetes cluster using only Terraform and bash — no GUI, no shortcuts</li>
  <li>Engineered a secure, cloud-native method to pass kubeadm join tokens using Secrets Manager</li>
  <li>Automated bootstrap scripts for hands-free provisioning and self-healing infrastructure</li>
  <li>Resolved kubelet/containerd misconfigurations and kernel-level networking prerequisites</li>
  <li>Debugged preflight join issues under time constraints — like a real-world fire drill</li>
  <li>Achieved seamless cross-node communication using Flannel CNI on hardened EC2 nodes</li>
</ul>

---

<h2 style="color:#AF7AC5;"><b>📘 Usage Instructions</b></h2>

```bash
# Initialize and apply the infrastructure
terraform init
terraform apply -auto-approve

# Master node will:
# - Install containerd, kubeadm, kubelet
# - Run kubeadm init
# - Push join command to AWS Secrets Manager

# Worker nodes will:
# - Install containerd, kubeadm, kubelet
# - Poll Secrets Manager until the join command appears
# - Join the cluster

<h2 style="color:#AF7AC5;"><b>🛠️ Prerequisites</b></h2>

Terraform >= 1.3.x

AWS CLI configured (aws configure)

IAM user with SecretsManager + EC2 permissions

AWS Free Tier eligibility

GitHub SSH key if using GitHub-hosted public keys for key pair





