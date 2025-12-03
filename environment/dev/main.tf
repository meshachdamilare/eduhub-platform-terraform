
module "networking" {
  source             = "../../modules/networking"
  env                = local.env
  enable_secondary   = var.enable_secondary
  enable_nat_gateway = var.enable_nat_gateway

  resource_group_name = var.resource_group_name
  location_primary    = var.location_primary
  location_secondary  = var.location_secondary

  address_space_primary   = local.primary_cidr
  address_space_secondary = local.secondary_cidr

  subnets_primary   = local.subnets_primary
  subnets_secondary = var.enable_secondary ? tomap(local.subnets_secondary) : tomap({})

  #   natgw_subnets_primary   = ["aks-nodes"]
  #   natgw_subnets_secondary = var.enable_secondary ? ["aks-nodes"] : []

}

module "aks_primary" {
  source = "../../modules/kubenertes"

  env                 = var.env
  location            = var.location_primary
  resource_group_name = module.networking.resource_group_name_primary
  cluster_name        = "${var.env}-aks-neu"
  dns_prefix          = "${var.env}-neu"

  # from networking module
  vnet_subnet_id = module.networking.subnet_ids_primary["aks-nodes"]
  outbound_type  = "loadBalancer"


  kubernetes_version        = null
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  private_cluster = false

  vm_size            = "Standard_D2s_v6"
  enable_autoscaling = true
  node_pool_name     = var.node_pool_name
  node_count         = 2
  min_count          = 2
  max_count          = 4

  tags = {
    "owner"   = "meshach",
    "service" = "lms"
    "env"     = "dev"
  }

  depends_on = [module.networking]
}

# module "aks_sec" {
#     source = "../../modules/kubenertes"

#     env = var.env
#     location = var.location_secondary
#     resource_group_name = module.networking.resource_group_name_sec
#     cluster_name = "${var.env}-aks-weu"
#     dns_prefix = "${var.env}-weu"

#     # from networking module
#     vnet_subnet_id = module.networking.subnet_ids_secondary["aks-nodes"]
#     outbound_type = "userAssignedNATGateway" 


#     kubernetes_version = null
#     oidc_issuer_enabled = true
#     workload_identity_enabled = true

#     private_cluster = false

#     acr_id = null

#     vm_size = "Standard_D2s_v6"
#     enable_autoscaling = true
#     min_count = 1
#     max_count = 3

#     tags = {
#         "owner" = "meshach",
#         "service" = "lms"
#         "env" = "dev"
#     }

#   depends_on = [ module.networking ]
# }