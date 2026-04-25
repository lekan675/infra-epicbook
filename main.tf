# ─── Resource Group ────────────────────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = "${var.application_name}-rg"
  location = var.location
}

# ─── Network Module ────────────────────────────────────────────────────────
module "network" {
  source                        = "./modules/network"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  application_name              = var.application_name
  vnet_address_space            = var.vnet_address_space
  public_subnet_address_prefix  = var.public_subnet_address_prefix
  private_subnet_address_prefix = var.private_subnet_address_prefix
}

# ─── Compute Module ────────────────────────────────────────────────────────
module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  application_name    = var.application_name
  admin_username      = var.admin_username
  vm_size             = var.vm_size
  public_key          = var.public_key
  public_subnet_id    = module.network.public_subnet_id
  ec2_nsg_id          = module.network.ec2_nsg_id
}

# ─── Database Module ───────────────────────────────────────────────────────
module "database" {
  source                 = "./modules/database"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = var.location
  application_name       = var.application_name
  db_admin_username      = var.db_admin_username
  db_name                = var.db_name
  private_subnet_id      = module.network.private_subnet_id
  private_dns_zone_id    = module.network.mysql_private_dns_zone_id
  mysql_dns_vnet_link_id = module.network.mysql_dns_vnet_link_id
}
