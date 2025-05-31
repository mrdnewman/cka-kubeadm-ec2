
<h1 align="center" style="color:#2E86C1;"><b>☁️ Bare Metal Kubernetes with Terraform + kubeadm + AWS Secrets Manager</b></h1>

<p align="center">
  <i>Deploy a fully functioning Kubernetes cluster using **Ubuntu 22.04**, **Terraform**, and **kubeadm** — no EKS, no shortcuts. Built for hands-on DevOps learning with full control of the control plane.</i>
</p>

---

<h2 style="color:#28B463;"><b>📌 Overview</b></h2>

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

📦 Linear Perspective

🏗️ Builds a K8s-ready VPC, Subnets, Security Groups, and EC2 Instances (via Terraform)

🔐 Creates a secure EC2 Key Pair using a GitHub-hosted public key

📜 Boots the master node with kubeadm init, sets up Flannel CNI

🔑 Pushes the worker kubeadm join command to AWS Secrets Manager

🤖 Worker nodes retrieve the join command and auto-join during bootstrap

⚙️ All nodes are configured to use containerd, not Docker

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

# Master node will bootstrap and push join command to AWS Secrets Manager
# Worker nodes will auto-join by retrieving the command at runtime


<h2 style="color:#DC7633;"><b>🛠️ Prerequisites</b></h2>
Terraform >= 1.3.x

AWS CLI configured (aws configure)

IAM user with SecretsManager + EC2 permissions

AWS Free Tier eligibility

GitHub SSH key if using GitHub-hosted public keys for key pair


<h2 style="color:#CD6155;"><b>📎 Resources</b></h2> <ul> <li><a href="https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/" style="color:#1F618D;"><b>Kubeadm Docs</b></a></li> <li><a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs" style="color:#1F618D;"><b>Terraform AWS Provider</b></a></li> <li><a href="https://docs.aws.amazon.com/secretsmanager/" style="color:#1F618D;"><b>AWS Secrets Manager</b></a></li> <li><a href="https://github.com/flannel-io/flannel" style="color:#1F618D;"><b>Flannel CNI</b></a></li> </ul>
<h2 align="center" style="color:#2ECC71;"><b>✨ Built for DevOps engineers who want to know how the sausage is made</b></h2> ```



