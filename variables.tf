# ─── General ───────────────────────────────────────────────────────────────
variable "application_name" {
  description = "Application name — used as prefix for all resources"
  type        = string
  default     = "myapp"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

# ─── Networking ────────────────────────────────────────────────────────────
variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_address_prefix" {
  description = "Public subnet CIDR — hosts the VM"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_address_prefix" {
  description = "Private subnet CIDR — hosts MySQL"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

# ─── Compute ───────────────────────────────────────────────────────────────
variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2ms"
}

# Path to the SSH public key file on the machine running terraform
# Default points to standard RSA key location
variable "public_key" {
  description = "Path to the SSH public key file (e.g. ~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# ─── Database ──────────────────────────────────────────────────────────────
variable "db_admin_username" {
  description = "MySQL administrator username"
  type        = string
  default     = "dbadmin"
}

variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "appdb"
}
