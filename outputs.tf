
output "master_ip" {
  value = module.master.public_ip
}

output "worker_ip" {
  value = [for i in module.worker : i.public_ip]
}

#output "worker_ip" {
#  value = module.worker.public_ip
#}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

