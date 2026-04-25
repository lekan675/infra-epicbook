variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "application_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "public_subnet_address_prefix" {
  type = list(string)
}

variable "private_subnet_address_prefix" {
  type = list(string)
}
