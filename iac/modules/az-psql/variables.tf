variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "location_code" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "dns_id" {
  type = string
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "sku" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "admin_password" {
  type      = string
  sensitive = true
}