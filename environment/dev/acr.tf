
module "container_regisry" {
  source              = "app.terraform.io/Teleios/terraform-azure-acr/azure"
  version             = "1.0.2"
  create_acr          = var.create_acr
  acr_name            = var.acr_name
  resource_group_name = module.networking.resource_group_name_primary
  acr_sku             = var.acr_sku
  tags                = var.tags

  depends_on = [module.networking]
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = module.container_regisry.acr_id
  role_definition_name = "AcrPull"
  
  principal_id         = module.aks_primary.kubelet_identity[0].object_id
  depends_on = [ module.container_regisry ]
}