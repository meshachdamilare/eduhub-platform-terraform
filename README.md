# Eduhub Platform – Terraform

This repository contains Terraform code to provision a secure environment for eduhub-platform on Azure.

It is structured around **reusable modules** (`modules/`) and **environment overlays** (`environment/dev`, `environment/stagging`, `environment/prod`).

---

### Project Structure

```text
terraform/
├── environment
│   ├── dev
│   │   ├── acr.tf
│   │   ├── apply-kubernetes-resources.tf
│   │   ├── argocd.tf
│   │   ├── blobstorage.tf
│   │   ├── cert-manager.tf
│   │   ├── cosmos.tf
│   │   ├── dev.tfvars
│   │   ├── ingress-controller.tf
│   │   ├── keyVault.tf
│   │   ├── kubernetes_resources/
│   │   │   ├── appofapps.yaml
│   │   │   └── cluster-issuer.yaml
│   │   ├── helmValues/
│   │   │   ├── argocd-values.yaml
│   │   │   ├── cert-manager.yaml
│   │   │   └── ingress-controller-values.yaml
│   │   ├── local.tf
│   │   ├── main.tf
│   │   ├── postgres.tf
│   │   ├── provider.tf
│   │   ├── redis.tf
│   │   ├── scripts/
│   │   │   └── createdb.sh
│   │   └── variables.tf
│   ├── stagging/
│   └── prod/
└── modules
    ├── database
    │   ├── cosmos/
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   └── variables.tf
    │   ├── posgres/
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   └── variables.tf
    │   └── redis/
    │       ├── main.tf
    │       ├── output.tf
    │       └── variables.tf
    ├── kubenertes/
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── networking/
    │   ├── dns.tf
    │   ├── local.tf
    │   ├── nat.tf
    │   ├── nsg.tf
    │   ├── output.tf
    │   ├── rg.tf
    │   ├── variable.tf
    │   ├── vnet.tf
    │   └── vnettpeering.tf
    └── storage/
        ├── main.tf
        ├── output.tf
        └── variables.tf
```


---

### Modules – What They Do & How They Connect

#### `modules/networking`

**What it does**

Creates all the network foundation:

- **Resource groups**
  - Primary: `env-resource_group_name-primary`
  - Optional secondary: `env-resource_group_name-sec`

- **Virtual Networks**
  - Primary VNet (e.g. `dev-vnet-north-europe`)
  - Optional secondary VNet (for multi-region scenarios)

- **Subnets (from `environment/dev/local.tf`)**
  - `aks-nodes` – where AKS node pools live
  - `data-private` – for data-plane services (databases, etc.)
  - `private-endpoints` – dedicated subnet for PaaS private endpoints (`disable_private_endpoint_policies = true`)

- **NSGs**
  - Created only for subnets that define `nsg_rules`.
  - Associated automatically with those subnets.

- **NAT Gateway (optional)**
  - Public IPs and NAT gateway.
  - Attached to subnets you list in `natgw_subnets_primary` / `natgw_subnets_secondary`.

- **Private DNS zones**
  - For PaaS private endpoints:
    - `privatelink.postgres.database.azure.com`
    - `privatelink.redis.cache.windows.net`
    - `privatelink.mongo.cosmos.azure.com`
    - `privatelink.blob.core.windows.net`
  - Linked to primary VNet (and secondary, if enabled).

- **VNet peering (optional)**
  - Primary ↔ Secondary VNet peering if `enable_secondary = true`.

**How others use it**

- `environment/dev/main.tf` uses this module.
  Implementation sample..

```hcl
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

  #natgw_subnets_primary   = ["aks-nodes"]
  #natgw_subnets_secondary = var.enable_secondary ? ["aks-nodes"] : []

}
```

- Other modules then consume its outputs:
  - `module.networking.resource_group_name_primary`
  - `module.networking.subnet_ids_primary["aks-nodes"]`
  - `module.networking.private_dns_zone_ids["privatelink.postgres.database.azure.com"]`
  - etc.

It is the **base** that everything else plugs into.

---

#### `modules/kubenertes` (AKS)

**What it does**

Creates an **AKS cluster** wired into the networking module.

Key features:

- AKS with `system-assigned identity`
- Overlay networking (`network_plugin = "azure"`, `network_plugin_mode = "overlay"`)
- Workload Identity + OIDC:
  - `oidc_issuer_enabled = true`
  - `workload_identity_enabled = true`
- Configurable node pool:
  - `vm_size`, `node_count`, autoscaling (`min_count`, `max_count`)
  - Uses `vnet_subnet_id` from networking module

**How it connects**

In `environment/dev/main.tf`:

```hcl
module "aks_primary" {
  source = "../../modules/kubenertes"

  env                 = var.env
  location            = var.location_primary
  resource_group_name = module.networking.resource_group_name_primary
  cluster_name        = "${var.env}-aks-neu"
  dns_prefix          = "${var.env}-neu"

  vnet_subnet_id = module.networking.subnet_ids_primary["aks-nodes"]
  outbound_type  = "loadBalancer"
  ...
}
```

Outputs that are used elsewhere:

- `module.aks_primary.kubelet_identity` → ACR `AcrPull` role assignment
- `module.aks_primary.oidc_issuer_url` → Key Vault / Workload Identity setup
- AKS info is used by the `helm` and `kubernetes` providers to install in-cluster components (Ingress, Argo CD, cert-manager, etc.)

---

#### `modules/database/posgres` (PostgreSQL)

**What it does**

- Creates a **PostgreSQL Flexible Server**.
- Supports two networking modes:
  - `"vnet"` – delegated subnet + private DNS zone
  - `"privatelink"` – private endpoint + private DNS zone
- Optional HA with zone-redundant pairs.
- Supports:
  - Password auth
  - Azure AD auth (with optional AAD admin)

**How it connects**

- Gets resource group, subnets, DNS zones from `modules/networking`.
- When `"privatelink"` mode is used:
  - Uses `private_endpoint_subnet_id` and `postgres_privatelink_dns_zone_id` from the networking module.

Example (currently commented in `environment/dev/postgres.tf`):

```hcl
module "postgres" {
  source                           = "../../modules/database/posgres"
  resource_group_name              = module.networking.resource_group_name_primary
  location                         = var.location_primary
  name                             = "meshach-pg-dev"
  network_mode                     = "privatelink"
  private_endpoint_subnet_id       = module.networking.subnet_ids_primary["private-endpoints"]
  postgres_privatelink_dns_zone_id = module.networking.private_dns_zone_ids["privatelink.postgres.database.azure.com"]
  ...
}
```

The `scripts/createdb.sh` script is a helper that uses `kubectl` and a temporary pod to create individual databases inside this server.

---

#### `modules/database/redis` (Azure Cache for Redis)

**What it does**

- Creates an **Azure Cache for Redis** (typically Premium).
- Disables public network access.
- Adds a **private endpoint** in the `private-endpoints` subnet.
- Registers it in the `privatelink.redis.cache.windows.net` private DNS zone.

**How it connects**

- Uses RG name, location from networking module.
- Uses `module.networking.subnet_ids_primary["private-endpoints"]`.
- Uses `module.networking.private_dns_zone_ids["privatelink.redis.cache.windows.net"]`.

---

####  `modules/database/cosmos` (Cosmos DB – Mongo API)

**What it does**

- Creates a **Cosmos DB** Mongo API account.
- Supports:
  - Single or multi-region (`geo_locations`)
  - Optional serverless mode
- Disables public access.
- Adds a private endpoint + DNS registration (`privatelink.mongo.cosmos.azure.com`).

**How it connects**

- Resource group & location from networking.
- Private endpoint subnet from networking.
- Private DNS zone from networking.

---

#### `modules/storage` (Blob Storage + CDN)

**What it does**

- Creates an Azure **Storage Account** (for videos/content).
- Creates a Blob **container** (default: `videos`).
- Optional:
  - Private endpoint to `privatelink.blob.core.windows.net`
  - CDN Profile + CDN Endpoint with the blob endpoint as origin.

**How it connects**

- Uses resource group and location from networking.
- Uses `private-endpoints` subnet + `privatelink.blob.core.windows.net` DNS zone when private endpoints are enabled.

**NOTE**

Azure PaaS resources such as Storage Accounts, PostgreSQL, Redis, and Cosmos DB do not reside inside your VNet.
These services run in Microsoft’s managed infrastructure and cannot be placed directly into subnets.

To make them private and accessible only within your network, we use Azure Private Link.

Private Link creates a Private Endpoint, a network interface with an IP from your `private-endpoints` subnet, Which provides secure, private connectivity to the PaaS service without exposing it to the public internet.

---

### Environment Layer (`environment/dev`)

The environment folder implements modules together and adds **cluster-level components**.

`main.tf`

- Calls **networking** module.
- Calls **AKS** module and points it at the `aks-nodes` subnet.

`provider.tf`

- Configures:
  - `azurerm` + `azuread` providers (for Azure resources).
  - `data "azurerm_kubernetes_cluster" "aks_primary"` to fetch kubeconfig for the AKS cluster created by `module.aks_primary`.
  - `kubernetes` and `helm` providers using that kubeconfig.

- This setup allows Terraform to:
  - Install **Helm charts** into the cluster.
  - Apply **Kubernetes manifests** using `kubernetes_manifest`.

`acr.tf`

- Uses a remote ACR module:
  - `module "container_regisry"` to create / configure ACR.
- Grants **AcrPull** role assignment to the AKS **kubelet identity** from `module.aks_primary`.

This is what allows AKS nodes to pull images from ACR.

`keyVault.tf`

- Creates:
  - Azure AD app + service principal for External Secrets Operator.
  - App registration for OIDC federation (`teleios-aks-federation`).
  - Federated identity credential tied to:
    - AKS OIDC issuer (`module.aks_primary.oidc_issuer_url`)
    - Service account subject: `system:serviceaccount:external-secrets-dev:external-secrets-sa`

- Creates a **Key Vault** and assigns **Key Vault Secrets User** role to the ESO service principal.

This allows ESO in the cluster to access Key Vault secrets via workload identity (no static SP credentials).



#### Helm-based Addons
`ingress-controller.tf`
- Installs ingress-nginx in `ingress-nginx` namespace.
- Values:
  - Health probe path.
  - `externalTrafficPolicy: Local`.

`cert-manager.tf`

- Installs cert-manager in `cert-manager` namespace.
- CRDs enabled via `helmValues/cert-manager.yaml`.

`argocd.tf`

- Installs Argo CD in `argocd` namespace.
- Values set things like:
  - Admin user, exec, reconciliation timeout.
  - Ingress with:
    - `ingressClassName: nginx`
    - `cert-manager.io/cluster-issuer: letsencrypt-prod`
    - Domain `argocd.meshachdevops.online` (customizable).
  - HA (multiple replicas for server, controller, repoServer, Redis disabled).

`apply-kubernetes-resources.tf`

Applies two important Kubernetes resources:

1. ClusterIssuer (`kubernetes_resources/cluster-issuer.yaml`)
   - Issuer name: `letsencrypt-prod`.
   - ACME configuration for Let’s Encrypt production.

2. Argo CD App-of-Apps (`kubernetes_resources/appofapps.yaml`)
   - Argo CD Application named `base-application`.
   - Points to Git repo: `https://github.com/meshachdamilare/eduhub-apps-gitops.git`.
   - Path: `applicationset` (recursive).
   - Automated sync + prune + self-heal.

This turns the cluster into a **GitOps platform** where Terraform only bootstraps Argo CD + base application, and Argo CD takes over application lifecycle.

---

#### How the Pieces Connect (Flow)

In order:

**Networking module**  
   ⮕ Creates RGs, VNets, subnets, DNS zones, NAT, peering.

**AKS module** (uses networking outputs)  
   ⮕ Cluster in the `aks-nodes` subnet.

**ACR module** (uses networking + AKS outputs)  
   ⮕ ACR + `AcrPull` role assignment to AKS kubelet identity.

**Key Vault + Workload Identity** (uses AKS OIDC + networking)  
   ⮕ KV + Entra App + federated identity for ESO.

**Helm Addons** (ingress, cert-manager, Argo CD)  
   ⮕ Installed via Helm provider against the AKS cluster.

**Kubernetes Manifest Resources**  
   ⮕ ClusterIssuer + App-of-Apps synced via Argo CD.

**Databases + Storage** (PostgreSQL, Redis and Storage)  
   ⮕ Use networking’s subnets and private DNS for private connectivity.

---

## Setup & Usage (Dev Environment)

**Prerequisites**

- Terraform **>= 1.6.0**
- Azure CLI (`az`)
- `kubectl`
- Access to the ACR Terraform module (`app.terraform.io/Teleios/terraform-azure-acr/azure`)
- An Azure subscription

**Configure Dev Variables**

Check `environment/dev/dev.tfvars` and adjust:

- `env` – e.g. `"dev"`
- `resource_group_name` – base name (e.g. `"final-teleios"`)
- `location_primary` – Azure region (e.g. `"north europe"`)
- `enable_secondary` – `false` for single-region dev
- `enable_nat_gateway` – `false` for now, or `true` if you want NAT
- ACR values (`create_acr`, `acr_sku`, `acr_name`)
- `postgres_admin_password` – use a strong secret if you enable Postgres

**Deploy Dev**

From repo root:

```bash
cd terraform/environment/dev

# login to Azure
az login
az account set --subscription "<your-subscription-id>"

# init
terraform init

# plan
terraform plan -var-file=dev.tfvars

# apply
terraform apply -var-file=dev.tfvars
```

This will:
- Build networking + AKS + ACR + Key Vault + AAD resources.
- Install ingress-nginx, cert-manager, Argo CD.
- Apply ClusterIssuer + App-of-Apps.

Access Argo CD
- Ensure DNS points to the ingress controller’s public IP.
- Visit `https://argocd.<your-domain>`.
- Use the admin credentials defined through Argo CD values (or default secret depending on config).

---

#### Adapting to Staging & Prod

- Copy `environment/dev` to `environment/stagging` and `environment/prod`.
- Change:
  - `env` in `*.tfvars` (`"stag"`, `"prod"`, etc.)
  - Regions and `resource_group_name`
  - Node sizes/counts
  - `enable_secondary = true` for multi-region/high availability
- Run `terraform init/plan/apply` from each environment folder separately.

Each environment is isolated in its own directory and state by default.
