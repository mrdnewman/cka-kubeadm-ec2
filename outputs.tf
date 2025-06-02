
output "master_ip" {
  value = module.master.public_ip
}

#output "worker_ip" {
#  value = module.worker.public_ip
#}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

#output "worker_ip" {
#  description = "Public IPs of all worker nodes"
#  value       = [for w in module.worker : w.public_ip]
#}

output "worker_ips" {
  description = "Map of worker names to public IPs"
  value = {
    for i, w in module.worker :
    "worker-${i + 1}" => w.public_ip
  }
}




