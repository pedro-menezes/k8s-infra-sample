output "postgres_password" {
  value     = random_password.postgres.result
  sensitive = true
}

output "key_vault_id" {
  value = azurerm_key_vault.this.id
}