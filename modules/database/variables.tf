variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "application_name" {
  type = string
}

variable "db_admin_username" {
  type = string
}

variable "db_name" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

# ── NEW: the VNet link ID — used to force MySQL to wait for DNS link ───────
variable "mysql_dns_vnet_link_id" {
  description = "ID of the DNS zone VNet link — ensures MySQL waits for link completion"
  type        = string
}
