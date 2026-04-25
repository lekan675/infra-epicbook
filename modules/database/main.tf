resource "random_string" "mysql_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ── Null resource used purely to force MySQL to wait for DNS VNet link ─────
resource "terraform_data" "dns_link_ready" {
  input = var.mysql_dns_vnet_link_id
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.application_name}-mysql-${random_string.mysql_suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.db_admin_username
  administrator_password = "DBAdmin@${var.application_name}2024!"
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"

  delegated_subnet_id = var.private_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  storage {
    size_gb = 20
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  # Wait for DNS VNet link to complete before creating MySQL server
  depends_on = [terraform_data.dns_link_ready]
}

resource "azurerm_mysql_flexible_database" "db" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
