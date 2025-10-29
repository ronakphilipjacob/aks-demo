locals {
  aks_node_pool_map = { for f in fileset("yamls/aks_node_pool", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/aks_node_pool/", f]))) }
}

resource "azurerm_kubernetes_cluster_node_pool" "nodePool" {
  for_each                    = local.aks_node_pool_map
  name                        = each.value.spec.name
  kubernetes_cluster_id       = local.aks_cluster_id[each.value.spec.aks_cluster]
  vm_size                     = each.value.spec.vm_size
  vnet_subnet_id              = local.subnet_id[each.value.spec.subnet]
  auto_scaling_enabled        = lookup(each.value.spec, "auto_scaling_enabled", false)
  max_count                   = lookup(each.value.spec, "max_count", null)
  min_count                   = lookup(each.value.spec, "min_count", null)
  node_count                  = each.value.spec.node_count

  zones                       = lookup(each.value.spec, "zones", null)
  temporary_name_for_rotation = lookup(each.value.spec, "temp_name_for_rotation", "temp${each.value.spec.name}")
  max_pods                    = lookup(each.value.spec, "max_pods", 50)
  node_labels                 = lookup(each.value.spec, "node_labels", {})

  tags = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}