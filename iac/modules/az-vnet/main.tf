resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.project}-${var.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.project}-${var.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = var.address_space
}

resource "azurerm_subnet" "main" {
  name                              = "snet-${var.project}-${var.env}"
  resource_group_name               = var.resource_group
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = var.subnet_address
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet" "database" {
  name                              = "snet-${var.project}-psql-${var.env}"
  resource_group_name               = var.resource_group
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = var.psql_subnet_address
  service_endpoints                 = ["Microsoft.Storage"]
  private_endpoint_network_policies = "Disabled"
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "database" {
  name                = "${var.project}.postgres.database.azure.com"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "database" {
  name                  = "vnetlink-${var.project}-${var.env}-${var.location_code}-001"
  private_dns_zone_name = azurerm_private_dns_zone.database.name
  virtual_network_id    = azurerm_virtual_network.this.id
  resource_group_name   = var.resource_group
  depends_on            = [azurerm_subnet.database]
}

resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-${var.project}-${var.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "this" {
  name                = "nat-${var.project}-${var.env}-${var.location_code}-001"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  subnet_id      = azurerm_subnet.main.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_subnet_nat_gateway_association" "database" {
  subnet_id      = azurerm_subnet.database.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}