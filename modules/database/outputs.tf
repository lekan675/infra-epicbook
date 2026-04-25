output "mysql_fqdn" {
  description = "MySQL Flexible Server FQDN (RDS endpoint equivalent)"
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}

output "mysql_server_name" {
  description = "MySQL server name"
  value       = azurerm_mysql_flexible_server.mysql.name
}
