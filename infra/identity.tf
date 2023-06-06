resource azurerm_user_assigned_identity chatbot {
  name                = "chatbot"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

# Assign the "Cognitive Services User" to the chatbot User Assigned identity
resource "azurerm_role_assignment" "chatbot_role_assignment" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Cognitive Services User"
  principal_id         = azurerm_user_assigned_identity.chatbot.principal_id
}