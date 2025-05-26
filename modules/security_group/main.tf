
resource "aws_security_group" "this" {
  name        = "cka-lab-sg"
  description = "Allow SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.allow_ssh_from_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cka-lab-sg"
  }
}

