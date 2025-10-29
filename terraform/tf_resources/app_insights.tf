locals {
  app_insights_map = { for f in fileset("yamls/app_insights", "*.yaml") : replace(f, ".yaml", "") => yamldecode(file(join("", ["yamls/app_insights/", f]))) }
  app_insights_id = {
    for k, v in local.app_insights_map :
      k => azurerm_application_insights.insights[k].id
  }
}

resource "azurerm_application_insights" "insights" {
  for_each             = local.app_insights_map
  name                 = each.value.spec.name
  location             = lookup(each.value.spec, "location", local.region)
  resource_group_name  = local.rg_name[each.value.spec.rg]
  application_type     = lookup(each.value.spec, "application_type", "other")
  daily_data_cap_in_gb = lookup(each.value.spec, "daily_data_cap_in_gb", 100)
  retention_in_days    = lookup(each.value.spec, "retention_in_days", 90)
  workspace_id         = local.log_analytics_workspace_id[each.value.spec.law]

  tags = merge(local.common_tags, lookup(each.value.spec, "tags", {}))
}