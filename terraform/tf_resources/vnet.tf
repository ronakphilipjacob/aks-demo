locals {
  vnet_map = { for f in fileset("yamls/vnet", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/vnet/", f]))) }

  vnet_id = {
    for k, v in local.vnet_map :
      k => azurerm_virtual_network.vnet[k].id
  }

  vnet_name = local.vnet_map != {} ? {
    for k, v in local.vnet_map :
      k => azurerm_virtual_network.vnet[k].name
  } : {}
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = local.vnet_map
  name                = each.value.spec.name
  location            = lookup(each.value.spec, "location", local.region)
  resource_group_name = local.rg_name[each.value.spec.rg]
  address_space       = each.value.spec.address_space
  tags                = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}