resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "azure-openai-terraform-deployment-sample"
}