# ─── Virtual Network (AWS VPC equivalent) ─────────────────────────────────
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.application_name}-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

# ─── Public Subnet (hosts the VM — AWS public subnet equivalent) ───────────
resource "azurerm_subnet" "public" {
  name                 = "${var.application_name}-public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.public_subnet_address_prefix
}

# ─── Private Subnet (hosts MySQL — AWS RDS private subnet equivalent) ──────
resource "azurerm_subnet" "private" {
  name                 = "${var.application_name}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.private_subnet_address_prefix

  # Delegated to MySQL Flexible Server (required for PaaS MySQL in a subnet)
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# ─── NSG for EC2/VM (allows SSH 22 and HTTP 80 from internet) ─────────────
# Equivalent to AWS Security Group for EC2
resource "azurerm_network_security_group" "ec2_nsg" {
  name                = "${var.application_name}-ec2-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow SSH — port 22
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP — port 80
  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ec2_nsg_assoc" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.ec2_nsg.id
}

# ─── NSG for RDS/MySQL (allows 3306 from EC2/VM subnet only) ──────────────
# Equivalent to AWS Security Group for RDS — source is the public subnet CIDR
resource "azurerm_network_security_group" "rds_nsg" {
  name                = "${var.application_name}-rds-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-mysql-from-ec2"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.public_subnet_address_prefix[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-other-inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "rds_nsg_assoc" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.rds_nsg.id
}

# ─── Private DNS Zone for MySQL Flexible Server ────────────────────────────
# Required so the VM can resolve the MySQL FQDN inside the VNet
resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = "${var.application_name}.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_link" {
  name                  = "${var.application_name}-mysql-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group_name
  registration_enabled  = false
}
