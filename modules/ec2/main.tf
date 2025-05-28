
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/../../scripts/${var.bootstrap_file_name}.tmpl", {
  master_ip = var.master_ip
})

  tags = {
    Name = var.instance_name
  }
}

