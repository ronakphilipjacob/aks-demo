locals {
  nsg_map = { for f in fileset("yamls/nsg", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/nsg/", f]))) }
  
  nsg_id = {
    for k, v in local.nsg_map :
      k => azurerm_network_security_group.nsg[k].id
  }

  nsg_name = {
    for k, v in local.nsg_map :
      k => azurerm_network_security_group.nsg[k].name
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = local.nsg_map
  name                = each.value.spec.name
  location            = lookup(each.value.spec, "location", local.region)
  resource_group_name = local.rg_name[each.value.spec.rg]

  dynamic "security_rule" {
    for_each = each.value.spec.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet_association" {
  for_each                  = local.nsg_map
  subnet_id                 = local.subnet_id[each.value.spec.subnet]
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}