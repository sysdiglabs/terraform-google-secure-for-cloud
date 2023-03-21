locals {
  project_ids = var.is_organizational ? var.project_ids : [var.project_id]
}

module "trust_relationship" {
  for_each = toset(local.project_ids)
  source   = "./trust_relationship"

  project_id                   = each.key
  role_name                    = var.role_name
  reuse_workload_identity_pool = var.reuse_workload_identity_pool
}
