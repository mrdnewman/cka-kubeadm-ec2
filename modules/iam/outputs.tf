

output "master_role_arn" {
  value = aws_iam_role.master.arn
}

output "worker_role_arn" {
  value = aws_iam_role.worker.arn
}

output "master_instance_profile_name" {
  value = aws_iam_instance_profile.master.name
}

output "worker_instance_profile_name" {
  value = aws_iam_instance_profile.worker.name
}


