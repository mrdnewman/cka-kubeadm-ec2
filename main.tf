
provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
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
  source              = "./modules/ec2"
  ami_id              = data.aws_ami.amazon_linux_2.id
  instance_type       = "t2.medium"
  key_name            = var.key_name
  subnet_id           = module.vpc.public_subnet_id
  security_group_id   = module.security_group.security_group_id
  instance_name       = "cka-master"
  bootstrap_file_name = "bootstrap-master.sh"
}

module "worker" {
  source              = "./modules/ec2"
  ami_id              = data.aws_ami.amazon_linux_2.id
  instance_type       = "t2.small"
  key_name            = var.key_name
  subnet_id           = module.vpc.public_subnet_id
  security_group_id   = module.security_group.security_group_id
  instance_name       = "cka-worker"
  bootstrap_file_name = "bootstrap-worker.sh"
}

