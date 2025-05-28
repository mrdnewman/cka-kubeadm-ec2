
resource "aws_security_group" "this" {
  name        = "cka-lab-sg"
  description = "Allow SSH access and internal K8s communication"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_ssh_from_cidr]
  }

  ingress {
    description = "Allow internal communication between nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cka-lab-sg"
  }
}


