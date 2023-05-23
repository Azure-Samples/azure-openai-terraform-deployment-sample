output "installation-script" {
  sensitive = true
  value = templatefile("installation_script.tftpl",
    { resourceGroup = azurerm_resource_group.this.name,
      aksName       = module.aks.aks_name,
      registry      = azurerm_container_registry.acr.name,
      endpoint      = module.openai.openai_endpoint,
      key           = module.openai.openai_primary_key,
    }
  )
}
