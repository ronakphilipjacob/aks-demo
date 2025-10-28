locals {
  acr_map = { for f in fileset("yamls/acr", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/acr/", f]))) }
  acr_id = {
    for k, v in local.acr_map :
      k => azurerm_container_registry.container_registry[k].id
  }
}

resource "azurerm_container_registry" "container_registry" {
  for_each            = local.acr_map
  name                = each.value.spec.name
  location            = lookup(each.value.spec, "location", local.region)
  resource_group_name = local.rg_name[each.value.spec.rg]

  sku                        = each.value.spec.sku
  admin_enabled              = lookup(each.value.spec, "admin_enabled", false)
  anonymous_pull_enabled     = lookup(each.value.spec, "anonymous_pull_enabled", false)
  
  tags = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}