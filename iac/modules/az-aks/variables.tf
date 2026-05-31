variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "location_code" {
  type = string
}

variable "location" {
  type    = string
  default = "Brazil South"
}

variable "resource_group" {
  type = string
}

variable "node_count" {
  type    = number
  default = 3
}

variable "node_size" {
  type    = string
  default = "Standard_D2_v2"
}

variable "default_node_pool_name" {
  type    = string
  default = "npsystem"
}

variable "subnet_id" {
  type = string
}

variable "user_assigned_id" {
  type = string
}

variable "user_assigned_principal_id" {
  type = string
}