data "google_organization" "org" {
  domain = var.organization_domain
}

data "google_projects" "org_projects" {
  filter = var.parent_folder_id == "" ? "lifecycleState:ACTIVE" : "parent.id:${var.parent_folder_id} lifecycleState:ACTIVE"
}


data "google_project" "project" {
  for_each = {
    for project_id in local.project_ids : project_id => project_id
  }
  project_id = each.key
}

locals {
  # If specific projects are specified, use that list. Otherwise, use all active projects in the org
  project_ids = length(var.project_ids) == 0 ? [for project in data.google_projects.org_projects.projects : project.project_id] : var.project_ids
  #[for p in data.google_projects.all_projects.projects : p.project_id] : var.project_ids

  # Fetch both the project ID and project number (Needed by Workload Identity Federation)
  project_id_to_number_map = { for project_id, project in data.google_project.project : project_id => project.number }
}

module "trust_relationship" {
  source                = "./trust_relationship"
  role_name             = var.role_name
  organization_domain   = var.organization_domain
  project_id            = var.project_id
  project_ids           = local.project_ids
  project_id_number_map = local.project_id_to_number_map
}
