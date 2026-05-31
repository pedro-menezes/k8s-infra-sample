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

variable "address_space" {
  type = list(string)
}

variable "subnet_address" {
  type = list(string)
}

variable "psql_subnet_address" {
  type = list(string)
}