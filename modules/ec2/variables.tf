
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

variable "bootstrap_file_name" {
  description = "The filename of the bootstrap script"
  type        = string
}

