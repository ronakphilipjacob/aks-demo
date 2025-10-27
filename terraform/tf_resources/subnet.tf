locals {
  subnet_map = { for f in fileset("yamls/subnet", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/subnet/", f]))) }
  
  subnet_id = {
    for k, v in local.subnet_map :
      k => azurerm_subnet.subnet[k].id
    }
}

resource "azurerm_subnet" "subnet" {
  for_each                                      = local.subnet_map
  name                                          = each.value.spec.name
  resource_group_name                           = local.rg_name[each.value.spec.rg]
  virtual_network_name                          = local.vnet_name[each.value.spec.virtual_network]
  address_prefixes                              = each.value.spec.address_prefix
}