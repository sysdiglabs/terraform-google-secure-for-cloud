###################################################
# Fetch & compute required data
###################################################

locals {
  project_ids = var.is_organizational ? var.project_ids : [var.project_id]
}

data "google_project" "project" {
  count      = length(local.project_ids)
  project_id = local.project_ids[count.index]
}

locals {
  project_numbers = [for p in data.google_project.project : p.number]
}

data "google_organization" "organization" {
  count  = var.organization_domain == "" ? 0 : 1
  domain = var.organization_domain
}
