output "mysql_fqdn" {
  description = "MySQL Flexible Server FQDN — use as db_host in Ansible"
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}

output "mysql_server_name" {
  description = "MySQL server short name"
  value       = azurerm_mysql_flexible_server.mysql.name
}

output "db_password" {
  description = "Auto-generated MySQL password — copy this into your pipeline variable group"
  value       = random_password.db_password.result
  sensitive   = false
}
