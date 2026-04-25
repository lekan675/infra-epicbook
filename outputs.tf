output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.compute.vm_public_ip
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = module.compute.vm_private_ip
}

output "mysql_fqdn" {
  description = "MySQL FQDN — use as db_host in Ansible"
  value       = module.database.mysql_fqdn
}

output "mysql_server_name" {
  description = "MySQL server short name"
  value       = module.database.mysql_server_name
}

output "mysql_username" {
  description = "Full MySQL username — Azure requires user@servername format"
  value       = "${var.db_admin_username}@${module.database.mysql_server_name}"
}

output "db_password" {
  description = "Auto-generated MySQL password — add this to your pipeline variable group as db_password"
  value       = module.database.db_password
  sensitive   = false
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -i id_rsa ${var.admin_username}@${module.compute.vm_public_ip}"
}

output "mysql_connect_from_vm" {
  description = "MySQL connect command to run from inside the VM"
  value       = "mysql -h ${module.database.mysql_fqdn} -P 3306 -u ${var.db_admin_username}@${module.database.mysql_server_name} -p${module.database.db_password}"
}
