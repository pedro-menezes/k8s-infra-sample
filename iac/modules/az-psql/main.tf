resource "azurerm_postgresql_flexible_server" "this" {
  name                          = "psql-${var.project}-${var.env}-${var.location_code}-001"
  resource_group_name           = var.resource_group
  location                      = var.location
  version                       = var.postgres_version
  delegated_subnet_id           = var.subnet_id
  private_dns_zone_id           = var.dns_id
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = var.admin_password
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name = var.sku
}