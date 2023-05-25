resource "random_string" "acr_suffix" {
  length  = 8
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_container_registry" "acr" {
  location            = azurerm_resource_group.this.location
  name                = "openai${random_string.acr_suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Premium"

  retention_policy {
    days    = 1
    enabled = true
  }
}