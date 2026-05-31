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

variable "sku" {
  type    = string
  default = "Premium"
}

variable "admin_enabled" {
  type    = bool
  default = false
}

variable "user_assigned_ids" {
  type = list(string)
}