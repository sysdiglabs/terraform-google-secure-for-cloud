###################################################
# Fetch & compute required data
###################################################

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

data "google_project" "project" {
  project_id = var.is_organizational ? var.project_ids[0] : var.project_id
}

data "google_organization" "organization" {
  count = var.organization_domain == "" ? 0 : 1

  domain = var.organization_domain
}

locals {
  benchmark_task_name   = var.is_organizational ? "Organization: ${data.google_organization.organization[0].org_id}" : data.google_project.project.name
  accounts_scope_clause = var.is_organizational ? "gcp.projectId in (\"${join("\", \"", var.project_ids)}\")" : "gcp.projectId = ${var.project_id}"
  regions_scope_clause  = length(var.regions) == 0 ? "" : " and gcp.region in (\"${join("\", \"", var.regions)}\")"
}

###################################################
# Configure Sysdig Backend
###################################################

resource "sysdig_secure_benchmark_task" "benchmark_task" {
  name     = "Sysdig Secure for Cloud (GCP) - ${local.benchmark_task_name}"
  schedule = "0 6 * * *"
  schema   = "gcp_foundations_bench-1.2.0"
  scope    = "${local.accounts_scope_clause}${local.regions_scope_clause}"
}
