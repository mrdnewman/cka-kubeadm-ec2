
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile to attach to the EC2 instance"
  type        = string
}

variable "bootstrap_file_name" {
  description = "The filename of the bootstrap script"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the instance"
  default     = {}
}

variable "cluster_name" {
  description = "K8s cluster name"
  type        = string
}

