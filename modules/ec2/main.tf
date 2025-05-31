
resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile

  tags = {
    Name = var.instance_name
  }

  user_data = file(var.bootstrap_file_name)

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

