# ─── Virtual Network ───────────────────────────────────────────────────────────
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.application_name}-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

# ─── Public Subnet — hosts the VM ─────────────────────────────────────────────
resource "azurerm_subnet" "public" {
  name                 = "${var.application_name}-public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.public_subnet_address_prefix
}

# ─── Private Subnet — delegated to MySQL Flexible Server ──────────────────────
# The delegation allows Azure to inject the MySQL service into this subnet
resource "azurerm_subnet" "private" {
  name                 = "${var.application_name}-private-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.private_subnet_address_prefix

  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# ─── NSG for VM — allows SSH (22) and HTTP (80) from internet ─────────────────
resource "azurerm_network_security_group" "ec2_nsg" {
  name                = "${var.application_name}-ec2-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

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

# ─── NSG for MySQL subnet ──────────────────────────────────────────────────────
# GRANTS VM ACCESS: allows port 3306 inbound from the VM's subnet only
# The VM (10.0.1.x) can reach MySQL (10.0.2.x) on port 3306
# All other inbound traffic is denied — MySQL is never reachable from the internet
resource "azurerm_network_security_group" "mysql_nsg" {
  name                = "${var.application_name}-mysql-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow MySQL port from the VM subnet (10.0.1.0/24) only
  security_rule {
    name                       = "allow-mysql-from-vm-subnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.public_subnet_address_prefix[0]
    destination_address_prefix = "*"
  }

  # Deny everything else — no public internet access to MySQL
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

resource "azurerm_subnet_network_security_group_association" "mysql_nsg_assoc" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.mysql_nsg.id
}

# ─── Private DNS Zone ──────────────────────────────────────────────────────────
# Resolves the MySQL FQDN to a private IP address inside the VNet
# Without this the VM cannot resolve the MySQL hostname
resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = "${var.application_name}.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

# ─── VNet Link — connects the DNS zone to the VNet ────────────────────────────
# Without this link the VM's DNS queries for the MySQL FQDN will fail
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_link" {
  name                  = "${var.application_name}-mysql-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group_name
  registration_enabled  = false
}
