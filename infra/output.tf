output "installation-script" {
  value = templatefile("installation_script.tftpl",
    { resourceGroup = azurerm_resource_group.this.name,
      aksName       = module.aks.aks_name,
      registry      = azurerm_container_registry.acr.name,
      endpoint      = module.openai.openai_endpoint,
      clientid      = azurerm_user_assigned_identity.chatbot.client_id,
      oidc_url      = module.aks.oidc_issuer_url,
    }
  )
}
