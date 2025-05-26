
variable "vpc_id" {
  type = string
}

variable "allow_ssh_from_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

