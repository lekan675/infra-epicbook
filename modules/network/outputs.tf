output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "ec2_nsg_id" {
  description = "ID of the VM Network Security Group"
  value       = azurerm_network_security_group.ec2_nsg.id
}

output "mysql_nsg_id" {
  description = "ID of the MySQL Network Security Group"
  value       = azurerm_network_security_group.mysql_nsg.id
}

output "mysql_private_dns_zone_id" {
  description = "ID of the private DNS zone for MySQL"
  value       = azurerm_private_dns_zone.mysql_dns.id
}

output "mysql_dns_vnet_link_id" {
  description = "ID of the DNS zone VNet link — MySQL server must wait for this"
  value       = azurerm_private_dns_zone_virtual_network_link.mysql_dns_link.id
}
