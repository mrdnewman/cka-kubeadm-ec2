
provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source             = "./modules/vpc"
  az     = data.aws_availability_zones.available.names[0]
  cidr_block         = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr= "10.0.2.0/24"
  name_prefix        = "cka-lab"
}

module "iam" {
  source             = "./modules/iam"
  master_role_name   = "k8s-master-role"
  worker_role_name   = "k8s-worker-role"
  kubeadm_secret_arn = "arn:aws:secretsmanager:us-west-2:366080763168:secret:kubeadmJoinCommand-ejqk8F"
}

module "key_pair" {
  source          = "./modules/key_pair"
  key_name        = var.key_name
  public_key_path = var.public_key_path
}

module "security_group" {
  source              = "./modules/security_group"
  vpc_id              = module.vpc.vpc_id
  allow_ssh_from_cidr = var.allow_ssh_from_cidr
}

module "master" {
  source               = "./modules/ec2"
  cluster_name         = var.cluster_name
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = "t2.medium"
  key_name             = var.key_name
  subnet_id            = module.vpc.public_subnet_id
  security_group_id    = module.security_group.security_group_id
  instance_name        = "cka-master"
  iam_instance_profile = module.iam.master_instance_profile_name
  #bootstrap_file_name  = "${path.root}/scripts/bootstrap-master.sh"
  bootstrap_file_name  = "${path.root}/scripts/bootstrap-master.sh.tpl"
  

}

module "worker" {
  source               = "./modules/ec2"
  count                = var.worker_count
  cluster_name         = var.cluster_name
  ami_id               = data.aws_ami.ubuntu.id
  instance_type        = "t2.medium"
  key_name             = var.key_name
  subnet_id            = module.vpc.public_subnet_id
  security_group_id    = module.security_group.security_group_id
  instance_name        = format("worker-%02d", count.index + 1)
  #instance_name       = "worker-${count.index}"
  #instance_name       = "cka-worker"
  iam_instance_profile = module.iam.worker_instance_profile_name
  #bootstrap_file_name  = "${path.root}/scripts/bootstrap-worker.sh"
  bootstrap_file_name  = "${path.root}/scripts/bootstrap-worker.sh.tpl"
}

