
resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile

  # Use either templatefile OR file, not both
  #user_data = templatefile("${path.module}/scripts/bootstrap-master.sh", {
  #  cluster_name = var.cluster_name
  #})

  user_data = templatefile(var.bootstrap_file_name, {
    cluster_name = var.cluster_name
  })

  tags = merge(
    var.tags,    # your common/global tags if any
    {
      Name = var.instance_name  # this is the magic tag for AWS Console name
    }
  )

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}
