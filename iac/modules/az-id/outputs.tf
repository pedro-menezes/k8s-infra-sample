output "user_assigned_identity" {
  value = azurerm_user_assigned_identity.this.id
}

output "user_assigned_principal_id" {
  value = azurerm_user_assigned_identity.this.principal_id
}