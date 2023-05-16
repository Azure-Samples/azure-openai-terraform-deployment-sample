module "openai" {
  source              = "git::https://github.com/Azure/terraform-azurerm-openai.git"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  private_endpoint = {
    "pe_endpoint" = {
      private_dns_entry_enabled       = true
      dns_zone_virtual_network_link   = "dns_zone_link_openai"
      is_manual_connection            = false
      name                            = "openai_pe"
      private_service_connection_name = "oepnai_pe_connection"
      subnet_name                     = "subnet0"
      vnet_name                       = module.vnet.vnet_name
      vnet_rg_name                    = azurerm_resource_group.this.name
    }
  }
  deployment = {
    "chat_model" = {
      name          = "gpt-35-turbo"
      model_format  = "OpenAI"
      model_name    = "gpt-35-turbo"
      model_version = "0301"
      scale_type    = "Standard"
    },
    "embedding_model" = {
      name          = "text-embedding-ada-002"
      model_format  = "OpenAI"
      model_name    = "text-embedding-ada-002"
      model_version = "1"
      scale_type    = "Standard"
    },
  }
  depends_on = [
    azurerm_resource_group.this,
    module.vnet
  ]
}