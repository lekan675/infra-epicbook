output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.compute.vm_public_ip
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = module.compute.vm_private_ip
}

output "mysql_fqdn" {
  description = "MySQL Flexible Server FQDN"
  value       = module.database.mysql_fqdn
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i id_rsa ${var.admin_username}@${module.compute.vm_public_ip}"
}
