variable "resource_group_name" {
  type        = string
  description = "Nome do resource group para o state do Terraform"
  default     = "rg-tfstate"
}

variable "storage_account_name" {
  type        = string
  description = "Nome da storage account"
  default     = "stterraformstate"
}

variable "container_name" {
  type        = string
  description = "Nome do container"
  default     = "tfstate"
}

variable "location" {
  type        = string
  description = "Região do Azure"
  default     = "Brazil South"
}