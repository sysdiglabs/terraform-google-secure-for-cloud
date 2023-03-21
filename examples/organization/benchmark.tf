locals {
  benchmark_projects_ids = length(var.benchmark_project_ids) == 0 ? [for p in data.google_projects.all_projects.projects : p.project_id] : var.benchmark_project_ids
}

module "cloud_bench" {
  providers = {
    google      = google.multiproject
    google-beta = google-beta.multiproject
  }

  count  = var.deploy_benchmark ? 1 : 0
  source = "../../modules/services/cloud-bench"

  is_organizational   = true
  organization_domain = var.organization_domain
  role_name           = "${var.name}${var.benchmark_role_name}"
  project_ids         = local.benchmark_projects_ids
}
