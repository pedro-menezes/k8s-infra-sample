resource "azurerm_container_registry" "this" {
  name                = "nsg-${var.project}-${var.env}-${var.location_code}-001"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each             = toset(var.user_assigned_ids)
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"

  principal_id = each.value
}