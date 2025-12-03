locals {
  env = var.env

  primary_cidr   = ["10.10.0.0/16"]
  secondary_cidr = ["10.20.0.0/16"]


  subnets_primary = {
    aks-nodes = {
      address_prefix    = "10.10.1.0/24",
      nsg_rules = []
    }

    data-private = {
      address_prefix    = "10.10.2.0/24",
      nsg_rules         = []
    }  

    private-endpoints = {
      address_prefix                    = "10.10.3.0/24",
      nsg_rules                         = []
      disable_private_endpoint_policies = true
    }
  }

  subnets_secondary = {
    aks-nodes = {
      address_prefix    = "10.20.1.0/24",
      nsg_rules = []
    }

    data-private = {
      address_prefix    = "10.20.2.0/24",
      nsg_rules         = []
    }

    private-endpoints = {
      address_prefix                    = "10.20.3.0/24",
      nsg_rules                         = []
      disable_private_endpoint_policies = true
    }
  }
}
