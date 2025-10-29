locals {
  log_analytics_workspace_map = { for f in fileset("yamls/log_analytics_workspace", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/log_analytics_workspace/", f]))) }
  
  log_analytics_workspace_id = {
    for k, v in local.log_analytics_workspace_map :
      k => azurerm_log_analytics_workspace.log_analytics_workspace[k].id
  }
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  for_each                           = local.log_analytics_workspace_map
  name                               = each.value.spec.name
  location                           = lookup(each.value.spec, "location", local.region)
  resource_group_name                = local.rg_name[each.value.spec.rg]
  sku                                = lookup(each.value.spec, "sku", "PerGB2018")
  retention_in_days                  = lookup(each.value.spec, "retention_in_days", 90)
  daily_quota_gb                     = lookup(each.value.spec, "daily_quota_gb", -1)
  allow_resource_only_permissions    = lookup(each.value.spec, "allow_resource_only_permissions", true)
  local_authentication_disabled      = lookup(each.value.spec, "local_authentication_disabled", false)
  internet_ingestion_enabled         = lookup(each.value.spec, "internet_ingestion_enabled", true)
  internet_query_enabled             = lookup(each.value.spec, "internet_query_enabled", true)
  reservation_capacity_in_gb_per_day = lookup(each.value.spec, "reservation_capacity_in_gb_per_day", null)
  data_collection_rule_id            = lookup(each.value.spec, "data_collection_rule_id", null)

  tags = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}

