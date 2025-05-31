


<h2 style="color:#AF7AC5;"><b>📘 Usage Instructions</b></h2>

# Initialize and apply the infrastructure

terraform init
terraform apply -auto-approve

- Master node will bootstrap and push join command to AWS Secret Manager
- Worker node will auto-join by retrieving the command at runtime


<h2 style="color:#DC7633;"><b>🛠️ ⚠️ Caveats and Notes</b></h2>

- This setup assumes Ubuntu 22.04 LTS (minimal AMI). Scripts are tailored for it.
- If the worker node tries to join before the master is ready, it may fail.
- This is now handled with a polling loop — no more sleep hacks.
- Ports 6443 (API server), 10250, and 8472/UDP (Flannel VXLAN) must be open between nodes.
- Your AWS user must have permissions for EC2 and Secrets Manager.
-If re-running Terraform, destroy old infra first (terraform destroy) to avoid conflicts.

<h2 style="color:#DC7633;"><b>🛠️ Prerequisites</b></h2>
Terraform >= 1.3.x

- AWS CLI configured (aws configure)
- IAM user with SecretsManager + EC2 permissions
- AWS Free Tier eligibility
- GitHub SSH key if using GitHub-hosted public keys for key pair

<h2 style="color:#CD6155;"><b>📎 Resources</b></h2> <ul> <li><a href="https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/" style="color:#1F618D;"><b>Kubeadm Docs</b></a></li> <li><a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs" style="color:#1F618D;"><b>Terraform AWS Provider</b></a></li> <li><a href="https://docs.aws.amazon.com/secretsmanager/" style="color:#1F618D;"><b>AWS Secrets Manager</b></a></li> <li><a href="https://github.com/flannel-io/flannel" style="color:#1F618D;"><b>Flannel CNI</b></a></li> </ul>

---

<h2 align="center">Built for DevOps/Plaform engineers who want to know how the sausage is made</h2>

