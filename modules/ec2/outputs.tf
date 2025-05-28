

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IP address of the instance"
}

output "instance_name" {
  value       = aws_instance.this.tags["Name"]
  description = "Name tag of the instance"
}

