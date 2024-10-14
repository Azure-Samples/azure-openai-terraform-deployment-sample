resource "azurerm_container_registry" "acr" {
  location            = azurerm_resource_group.this.location
  name                = "openai${module.naming.container_registry.name_unique}"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Premium"

  retention_policy {
    days    = 1
    enabled = true
  }
}