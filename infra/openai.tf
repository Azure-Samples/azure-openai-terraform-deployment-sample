module "openai" {
  source              = "Azure/openai/azurerm"
  version             = "0.1.3"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  private_endpoint = {
    "pe_endpoint" = {
      private_dns_entry_enabled       = true
      dns_zone_virtual_network_link   = "dns_zone_link_openai"
      is_manual_connection            = false
      name                            = "openai_pe"
      private_service_connection_name = "openai_pe_connection"
      subnet_name                     = "subnet0"
      vnet_name                       = module.vnet.vnet_name
      vnet_rg_name                    = azurerm_resource_group.this.name
    }
  }
  deployment = {
    "chat_model" = {
      name          = var.chat_model_name
      model_format  = "OpenAI"
      model_name    = var.chat_model_name
      model_version = var.chat_model_version
      scale_type    = var.scale_type
      capacity      = 30
    },
    "embedding_model" = {
      name          = "text-embedding-ada-002"
      model_format  = "OpenAI"
      model_name    = "text-embedding-ada-002"
      model_version = "2"
      scale_type    = "Standard"
      capacity      = 120
    },
  }
  depends_on = [
    azurerm_resource_group.this,
    module.vnet
  ]
}
