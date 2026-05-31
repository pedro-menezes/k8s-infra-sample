locals {
  region_codes = {
    "Brazil South"     = "brs"
    "Brazil Southeast" = "bse"
    "East US"          = "eus"
    "East US 2"        = "eus2"
  }

  common_tags = {
    managed_by = "terragrunt"
    project    = "desafio"
  }
}

# remote_state {
#   backend = "azurerm"

#   config = {
#     resource_group_name  = "rg-tfstate"
#     storage_account_name = "stterraformstate"
#     container_name       = "tfstate"
#     key                  = "${path_relative_to_include()}/terraform.tfstate"
#   }
# }

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.74.0"
    }
  }
}

provider "azurerm" {
  features {}
}
EOF
}

# generate "backend" {
#   path      = "backend.tf"
#   if_exists = "overwrite"
#   contents  = <<EOF
# terraform {
#   backend "azurerm" {}
# }
# EOF
# }