locals {
  resource_id_map = merge(
    local.acr_id != null ? { for k, v in local.acr_id : join("_", [k, "acr"]) => v } : {}
  )
}