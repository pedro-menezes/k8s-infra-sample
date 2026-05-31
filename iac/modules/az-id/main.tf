resource "azurerm_user_assigned_identity" "this" {
  name                = "id-${var.project}-${var.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group
}