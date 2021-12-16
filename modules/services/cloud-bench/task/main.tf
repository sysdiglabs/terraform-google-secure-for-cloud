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

locals {
  benchmark_task_name   = var.is_organizational ? "Organization: ${data.google_organization.organization[0].org_id}" : trimprefix(data.google_project.project[0].id, "projects/")
  accounts_scope_clause = var.is_organizational ? "gcp.projectId in (\"${join("\", \"", local.project_numbers)}\")" : "gcp.projectId = \"${local.project_numbers[0]}\""
  regions_scope_clause  = length(var.regions) == 0 ? "" : " and gcp.region in (\"${join("\", \"", var.regions)}\")"
}

###################################################
# Configure Sysdig Backend
###################################################

resource "random_integer" "minute" {
  max = 59
  min = 0
}

resource "random_integer" "hour" {
  max = 23
  min = 0
}

resource "sysdig_secure_benchmark_task" "benchmark_task" {
  name     = "Sysdig Secure for Cloud (GCP) - ${local.benchmark_task_name}"
  schedule = "${random_integer.minute.result} ${random_integer.hour.result} * * *"
  schema   = "gcp_foundations_bench-1.2.0"
  scope    = "${local.accounts_scope_clause}${local.regions_scope_clause}"
}
