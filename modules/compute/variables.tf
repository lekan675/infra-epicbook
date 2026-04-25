variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "application_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "vm_size" {
  type = string
}

# Path to the SSH public key file — e.g. ~/.ssh/id_rsa.pub
variable "public_key" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "public_subnet_id" {
  type = string
}

variable "ec2_nsg_id" {
  type = string
}
