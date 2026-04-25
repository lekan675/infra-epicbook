output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "ec2_nsg_id" {
  description = "ID of the EC2/VM Network Security Group"
  value       = azurerm_network_security_group.ec2_nsg.id
}

output "rds_nsg_id" {
  description = "ID of the RDS/MySQL Network Security Group"
  value       = azurerm_network_security_group.rds_nsg.id
}

output "mysql_private_dns_zone_id" {
  description = "ID of the private DNS zone for MySQL"
  value       = azurerm_private_dns_zone.mysql_dns.id
}

# ── NEW: export the VNet link ID so database module can depend on it ───────
output "mysql_dns_vnet_link_id" {
  description = "ID of the private DNS zone VNet link — MySQL server must wait for this"
  value       = azurerm_private_dns_zone_virtual_network_link.mysql_dns_link.id
}
