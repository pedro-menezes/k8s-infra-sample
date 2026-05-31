include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  root          = read_terragrunt_config(find_in_parent_folders())
  location      = "Brazil South"
  location_code = local.root.locals.region_codes[local.location]
}

terraform {
  source = "../../modules//aks-cluster"
}

inputs = {
  project             = "cluster"
  env                 = "stg"
  resource_group      = "rg-cluster-stg"
  location            = "Brazil South"
  location_code       = local.location_code
  address_space       = ["10.1.0.0/16"]
  subnet_address      = ["10.1.1.0/24"]
  psql_subnet_address = ["10.1.2.0/24"]

  tags = merge(
    local.root.locals.common_tags,
    {
      environment = "stg"
    }
  )
}