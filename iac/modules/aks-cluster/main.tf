module "vnet" {
  source              = "../az-vnet"
  env                 = var.env
  project             = var.project
  location            = var.location
  location_code       = var.location_code
  resource_group      = var.resource_group
  address_space       = var.address_space
  subnet_address      = var.subnet_address
  psql_subnet_address = var.psql_subnet_address
}

module "id" {
  source         = "../az-id"
  env            = var.env
  project        = var.project
  location       = var.location
  location_code  = var.location_code
  resource_group = var.resource_group
}

module "kv" {
  source                 = "../az-kv"
  env                    = var.env
  project                = var.project
  location               = var.location
  location_code          = var.location_code
  resource_group         = var.resource_group
  user_assigned_identity = module.id.user_assigned_principal_id
}

module "psql" {
  source         = "../az-psql"
  env            = var.env
  project        = var.project
  location       = var.location
  location_code  = var.location_code
  resource_group = var.resource_group
  subnet_id      = module.vnet.psql_subnet_id
  dns_id         = module.vnet.dns_id
  admin_password = module.kv.postgres_password
}

module "cr" {
  source            = "../az-cr"
  env               = var.env
  project           = var.project
  location          = var.location
  location_code     = var.location_code
  resource_group    = var.resource_group
  user_assigned_ids = [module.id.user_assigned_principal_id]
}

module "aks" {
  source                     = "../az-aks"
  env                        = var.env
  project                    = var.project
  location                   = var.location
  location_code              = var.location_code
  resource_group             = var.resource_group
  subnet_id                  = module.vnet.subnet_id
  user_assigned_id           = module.id.user_assigned_identity
  user_assigned_principal_id = module.id.user_assigned_principal_id
}