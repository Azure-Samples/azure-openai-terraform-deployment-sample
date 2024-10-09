resource "random_integer" "this" {
  max = 999999
  min = 100000
}

module "openai" {
  source              = "Azure/avm-res-cognitiveservices-account/azurerm"
  version             = "0.4.0"
  kind                = "OpenAI"
  name                = "azure-openai-${random_integer.this.result}"
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = "S0"
  location            = azurerm_resource_group.this.location
  private_endpoints = {
    "pe_endpoint" = {
      name                            = "openai_pe"
      private_dns_zone_resource_ids   = toset([azurerm_private_dns_zone.zone.id])
      private_service_connection_name = "openai_pe_connection"
      subnet_resource_id              = module.vnet.vnet_subnets_name_id["subnet0"]
    }
  }
  cognitive_deployments  = {
    "chat_model" = {
      name          = var.chat_model_name
      model = {
        format  = "OpenAI"
        name    = var.chat_model_name
        version = var.chat_model_version
      }
      scale = {
        capacity = 120
        type     = var.scale_type
      }
    },
    "embedding_model" = {
      name          = var.emb_model_name
      model = {
        format  = "OpenAI"
        name    = var.emb_model_name
        version = "2"
      }
      scale = {
        capacity = 120
        type     = var.scale_type
      }
    },
  }
  network_acls = {
    default_action = "Deny"
    virtual_network_rules = toset([{subnet_id = module.vnet.vnet_subnets_name_id["subnet0"]}])
  }
  depends_on = [
    azurerm_resource_group.this,
    module.vnet
  ]
}
