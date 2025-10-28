locals {
  role_assignment_map = { for f in fileset("yamls/role_assignment", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/role_assignment/", f]))) }
}

resource "azurerm_role_assignment" "role_assignment" {
  for_each             = local.role_assignment_map
  scope                = local.resource_id_map[each.value.spec.scope]
  role_definition_name = each.value.spec.role_definition
  principal_id         = local.managed_identity_principal_id[each.value.spec.managed_identity]
}