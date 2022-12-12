locals {
  project_ids = var.is_organizational ? var.project_ids : [var.project_id]
}

module "trust_relationship" {
  source              = "./trust_relationship"
  role_name           = var.role_name
  organization_id     = var.org_id
  project_ids         = local.project_ids
  organization_domain = var.organization_domain
  project_id = var.project_id
}

module "task" {
  source              = "./task"
  project_id          = var.project_id
  project_ids         = local.project_ids
  regions             = var.regions
  is_organizational   = var.is_organizational
  organization_domain = var.organization_domain

  depends_on = [module.trust_relationship]
}
