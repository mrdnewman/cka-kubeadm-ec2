
output "master_ip" {
  value = module.master.public_ip
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "worker_ips" {
  value = {
    for idx, ip in module.worker.*.public_ip :
    "cka-worker-${idx + 1}" => ip
  }
}

