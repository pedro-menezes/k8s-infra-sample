data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = "kv-${var.project}-${var.env}-${var.location_code}-001"
  location                    = var.location
  resource_group_name         = var.resource_group
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  rbac_authorization_enabled  = true
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.user_assigned_identity
}

resource "random_password" "postgres" {
  length           = 32
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>?"
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-password"
  value        = random_password.postgres.result
  key_vault_id = azurerm_key_vault.this.id
}