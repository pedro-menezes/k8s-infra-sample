output "resource_group_name" {
  value       = azurerm_resource_group.tfstate.name
  description = "Nome do resource group"
}

output "storage_account_name" {
  value       = azurerm_storage_account.tfstate.name
  description = "Nome da storage"
}

output "container_name" {
  value       = azurerm_storage_container.tfstate.name
  description = "Nome do container"
}