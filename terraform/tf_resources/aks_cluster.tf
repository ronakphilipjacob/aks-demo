locals {
  aks_cluster_map = { for f in fileset("yamls/aks", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/aks/", f]))) }
  
  aks_cluster_id = {
      for k, v in local.aks_cluster_map :
      k => azurerm_kubernetes_cluster.aks[k].id
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each            = local.aks_cluster_map
  name                = each.value.spec.name
  location            = lookup(each.value.spec, "location", local.region)
  resource_group_name = local.rg_name[each.value.spec.ibm-prism-spec.rg]
  node_resource_group = lookup(each.value.spec, "node_resource_group", null)
  sku_tier            = lookup(each.value.spec, "sku_tier", "Free")
  dns_prefix          = each.value.spec.dns_prefix
  kubernetes_version  = lookup(each.value.spec, "kubernetes_version", null)

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = lookup(each.value.spec.ibm-prism-spec, "azure_rbac_enabled", null)
  }

  default_node_pool {
    name                        = each.value.spec.default_node_pool_name
    node_count                  = each.value.spec.node_count
    vm_size                     = each.value.spec.vm_size
    vnet_subnet_id              = local.subnet_id[each.value.spec.vnet_subnet]
    zones                       = lookup(each.value.spec, "zones", null)
    temporary_name_for_rotation = lookup(each.value.spec, "temp_name_for_rotation", "tempdefault")
    max_pods                    = lookup(each.value.spec, "max_pods", 50)
  }

  # identity {
  #   type         = each.value.spec.identity_type
  #   identity_ids = [local.managed_identity[each.value.spec.managed_identity]]
  # }

  network_profile {
    network_plugin    = each.value.spec.network_plugin
    network_policy    = each.value.spec.network_policy
    load_balancer_sku = each.value.spec.load_balancer_sku
    service_cidr      = lookup(each.value.spec, "service_cidr", null)
    dns_service_ip    = lookup(each.value.spec, "dns_service_ip", null)
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = each.value.spec.secret_rotation_enabled
    secret_rotation_interval = each.value.spec.secret_rotation_interval
  }

  tags = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}