
# Azure AD + AKS Federated Identity + Key Vault Setup  
# Terraform AzureAD v3+, Azurerm v4.x                  


# Get info about current Azure credentials
data "azurerm_client_config" "current" {}


# Azure AD Application for Service Principal
resource "azuread_application" "eso_app" {
  display_name = "teleios-mesh-wi-app"
  owners = [data.azurerm_client_config.current.object_id]
}

# Service Principal for the above application
resource "azuread_service_principal" "eso_sp" {
  client_id                    = azuread_application.eso_app.client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

# This is needed to create Federated Identity Credentials
resource "azuread_application_registration" "aks_oidc_app" {
  display_name = "teleios-aks-federation"
}

# Federated Identity Credential allows AKS Service Account to authenticate to Azure AD
resource "azuread_application_federated_identity_credential" "aks_oidc_federation" {
  application_id = azuread_application_registration.aks_oidc_app.id
  display_name   = "external-secrets-oidc-federation"
  description    = "Allows AKS ESO service account to authenticate with Azure AD"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = module.aks_primary.oidc_issuer_url
  subject        = "system:serviceaccount:external-secrets-dev:external-secrets-sa"
}

#Azure Key Vault
resource "azurerm_key_vault" "eso_kv" {
  name                        = "teleios-eso-kv"
  location                    = var.location_primary
  resource_group_name         = module.networking.resource_group_name_primary
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                     = "standard"
  purge_protection_enabled     = false
  soft_delete_retention_days   = 7
}

# Key Vault role definition
data "azurerm_role_definition" "kv_secrets_user" {
  name  = "Key Vault Secrets User"
  scope = azurerm_key_vault.eso_kv.id
}

# Assign Key Vault access to the ESO Service Principal
resource "azurerm_role_assignment" "kv_role" {
  scope              = azurerm_key_vault.eso_kv.id
  role_definition_id = data.azurerm_role_definition.kv_secrets_user.id
  principal_id       = azuread_service_principal.eso_sp.object_id  
}
