data "google_organization" "org" {
  domain = var.organization_domain
}

data "google_projects" "all_projects" {
  filter = "parent.id:${data.google_organization.org.org_id} parent.type:organization lifecycleState:ACTIVE"
}

locals {
  # If specific projects are specified, use that list. Otherwise, use all active projects in the org
  project_ids = length(var.project_ids) == 0 ? [for p in data.google_projects.all_projects.projects : p.project_id] : var.project_ids

  # Fetch both the project ID and project number (Needed by Workload Identity Federation)
  project_id_to_number_map = { for p in data.google_projects.all_projects.projects : p.project_id => p.number }
}

module "trust_relationship" {
  source                = "./trust_relationship"
  role_name             = var.role_name
  organization_domain   = var.organization_domain
  project_id            = var.project_id
  project_ids           = local.project_ids
  project_id_number_map = local.project_id_to_number_map
}
