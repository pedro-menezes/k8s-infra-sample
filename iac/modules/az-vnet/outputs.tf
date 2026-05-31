output "subnet_id" {
  value = azurerm_subnet.main.id
}

output "psql_subnet_id" {
  value = azurerm_subnet.database.id
}

output "dns_id" {
  value = azurerm_private_dns_zone.database.id
}