locals {
  route_table_map = { for f in fileset("yamls/route_table", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/route_table/", f]))) if lookup(yamldecode(file(join("", ["yamls/route_table/", f]))).spec.ibm-prism-spec, "deploy", true) != false }
  rt_id = {
    for k, v in local.route_table_map :
    k => azurerm_route_table.rt[k].id
  }
}

resource "azurerm_route_table" "rt" {
  for_each                      = local.route_table_map
  name                          = each.value.metadata.name
  location                      = lookup(each.value.spec.ibm-prism-spec, "location", local.region)
  resource_group_name           = lookup(each.value.spec.ibm-prism-spec, "resource_group_name", try(local.rg_name[each.value.spec.ibm-prism-spec.resource_group], null))
  bgp_route_propagation_enabled = lookup(each.value.spec.ibm-prism-spec, "bgp_route_propagation_enabled", false)

  dynamic "route" {
    for_each = each.value.spec.ibm-prism-spec.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_type == "VirtualAppliance" ? try(data.azurerm_firewall.fwl_data.ip_configuration[0].private_ip_address, null) : lookup(route.value, "next_hop_in_ip_address", null)
    }
  }

  tags = merge(local.common_tags, lookup(each.value.spec.ibm-prism-spec, "tags", {}))
}

resource "azurerm_subnet_route_table_association" "rt_association" {
  for_each       = local.route_table_map
  subnet_id      = local.subnet_id[each.value.spec.ibm-prism-spec.subnet]
  route_table_id = azurerm_route_table.rt[each.key].id
}