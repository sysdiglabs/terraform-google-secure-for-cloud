locals {
  project_ids = var.is_organizational ? var.project_ids : [var.project_id]
}

module "trust_relationship" {
  for_each = toset(var.project_ids)
  source   = "./trust_relationship"

  project_id = each.key
}

module "task" {
  source              = "./task"
  project_ids         = local.project_ids
  is_organizational   = true
  organization_domain = var.organization_domain

  depends_on = [module.trust_relationship]
}
