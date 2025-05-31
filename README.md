
<h1 align="center" style="color:#2E86C1;"><b>☁️ Bare Metal K8s with Terraform + kubeadm + AWS Secrets Manager</b></h1>

<p align="center">
  <i>Deploy a fully functioning Kubernetes cluster using **Ubuntu 22.04**, **Terraform**, and **kubeadm** — no EKS, no shortcuts. Built for hands-on DevOps learning and **CKA Certification Prep.</i>
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
  <li>Built a dynamic Kubernetes cluster using only Terraform and raw EC2, bash — no GUI, no shortcuts</li>
  <li>Engineered a secure, cloud-native method to pass kubeadm join tokens using Secrets Manager</li>
  <li>Built resilient worker bootstrap scripts with join polling logic</li>
  <li>Resolved kubelet/containerd misconfigurations and kernel-level networking prerequisites</li>
  <li>Debugged preflight join issues under time constraints — like a real-world fire drill</li>
  <li>Achieved seamless cross-node communication using Flannel CNI on hardened EC2 nodes</li>
  <li>Hardened infra by minimizing public exposure and enforcing least privilege IAM</li>
</ul>

---

<h2 style="color:#AF7AC5;"><b>📘 Usage Instructions</b></h2>

# Initialize and apply the infrastructure
terraform init
terraform apply -auto-approve

- **Creates Network Infrastructure**
   - VPC, subnet, internet gateway, route tables
   - Security group with open ports required for Kubernetes cluster comms (6443, 22, etc.)

- **Provisions EC2 instances**
   - Master node and worker nodes using Ubuntu 22.04 AMI
   - Each instance gets a public IP (for lab/demo use)
   - Injects a bootstrap shell script via `user_data` for auto-configuration

- **Creates SSH key pair**
   - If using GitHub SSH key, it pulls your public key and registers it as an AWS key pair

- **Creates AWS Secrets Manager entry**
   - A named secret (e.g., `/k8s/joincommand`) is created and left empty
   - The master node will later push the actual join command here at runtime


- **Master node will:**
- Install containerd, kubeadm, kubelet
- Run kubeadm init
- Push join command to AWS Secrets Manager

- **Worker nodes will:**
- Install containerd, kubeadm, kubelet
- Poll Secrets Manager until the join command appears
- Join the cluster

---

<h2 style="color:#DC7633;"><b>🛠️ ⚠️ Caveats and Notes</b></h2>

- This setup assumes Ubuntu 22.04 LTS (minimal AMI). Scripts are tailored for it.
- If the worker node tries to join before the master is ready, it may fail.
- This is now handled with a polling loop — no more sleep hacks.
- Ports 6443 (API server), 10250, and 8472/UDP (Flannel VXLAN) must be open between nodes.
- Your AWS user must have permissions for EC2 and Secrets Manager.
-If re-running Terraform, destroy old infra first (terraform destroy) to avoid conflicts.

---

<h2 style="color:#DC7633;"><b>🛠️ Prerequisites</b></h2>
Terraform >= 1.3.x

- AWS CLI configured (aws configure)
- IAM user with SecretsManager + EC2 permissions
- AWS Free Tier eligibility
- GitHub SSH key if using GitHub-hosted public keys for key pair

---

<h2 style="color:#CD6155;"><b>📎 Resources</b></h2> <ul> <li><a href="https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/" style="color:#1F618D;"><b>Kubeadm Docs</b></a></li> <li><a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs" style="color:#1F618D;"><b>Terraform AWS Provider</b></a></li> <li><a href="https://docs.aws.amazon.com/secretsmanager/" style="color:#1F618D;"><b>AWS Secrets Manager</b></a></li> <li><a href="https://github.com/flannel-io/flannel" style="color:#1F618D;"><b>Flannel CNI</b></a></li> </ul>

---

### ✨ *Built for DevOps/Platform engineers who want to know how the sausage is made*  

