# ─── Random suffix — globally unique MySQL server name ─────────────────────
resource "random_string" "mysql_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ─── Auto-generated DB password ────────────────────────────────────────────
# No need to pass a password — Terraform generates and manages it
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# ─── Force MySQL to wait for the DNS VNet link ─────────────────────────────
# Prevents: VnetNotLinkedToPrivateDnsZone error
resource "terraform_data" "dns_link_ready" {
  input = var.mysql_dns_vnet_link_id
}

# ─── MySQL Flexible Server — private access via delegated subnet ───────────
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.application_name}-mysql-${random_string.mysql_suffix.result}"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.db_admin_username
  administrator_password = random_password.db_password.result
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"

  # Private — lives in delegated subnet, never exposed to the internet
  delegated_subnet_id = var.private_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  storage {
    size_gb = 20
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  depends_on = [terraform_data.dns_link_ready]
}

# ─── Disable SSL — VM connects over private VNet so SSL is not needed ──────
resource "azurerm_mysql_flexible_server_configuration" "disable_ssl" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "OFF"
}

# ─── Application database ──────────────────────────────────────────────────
resource "azurerm_mysql_flexible_database" "db" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}
