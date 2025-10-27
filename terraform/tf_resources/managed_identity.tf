locals {
  managed_identity_map = { for f in fileset("yamls/managed_identity", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/managed_identity/", f]))) }
  
  managed_identity_id = {
      for k, v in local.managed_identity_map :
        k => azurerm_user_assigned_identity.managed_identity[k].id
  }
}


resource "azurerm_user_assigned_identity" "managed_identity" {
  for_each            = local.managed_identity_map
  location            = lookup(each.value.spec, "location", local.region)
  name                = each.value.metadata.name
  resource_group_name = local.rg_name[each.value.spec.rg]
  tags                = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}