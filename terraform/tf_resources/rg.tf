locals {
  rg_map = { for f in fileset("yamls/rg", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/rg/", f]))) }
  rg = {
    for k, v in local.rg_map :
      k => azurerm_resource_group.rg[k].id
  }
  rg_name = {
    for k, v in local.rg_map :
      k => azurerm_resource_group.rg[k].name
  }
}

resource "azurerm_resource_group" "rg" {
  for_each = local.rg_map
  name     = each.value.spec.name
  location = lookup(each.value.spec, "location", local.region)
  tags     = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}