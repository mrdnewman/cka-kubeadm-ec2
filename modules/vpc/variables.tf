
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "az" {
  description = "Availability zone for subnets"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for naming AWS resources"
  type        = string
  default     = "cka-lab"
}

