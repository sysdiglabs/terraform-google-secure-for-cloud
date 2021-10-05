###################################################
# Fetch & compute required data
###################################################

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

data "google_project" "project" {
  project_id = var.project_id
}

locals {
  regions_scope_clause = length(var.regions) == 0 ? "" : " and gcp.region in (\"${join("\", \"", var.regions)}\")"
}

###################################################
# Configure Sysdig Backend
###################################################

resource "sysdig_secure_cloud_account" "cloud_account" {
  account_id     = data.google_project.project.number
  alias          = data.google_project.project.name
  cloud_provider = "gcp"
  role_enabled   = "true"
  role_name      = "${var.naming_prefix}_cloudbench"
}

resource "sysdig_secure_benchmark_task" "benchmark_task" {
  name     = "Sysdig Secure for Cloud (GCP) - ${data.google_project.project.name}"
  schedule = "0 6 * * *"
  schema   = "gcp_foundations_bench-1.2.0"
  scope    = "gcp.projectId = \"${data.google_project.project.number}\"${local.regions_scope_clause}"

  # Creation of a task requires that the Cloud Account already exists in the backend, and has `role_enabled = true`
  # We also don't want to create the benchmark task until the provider pool, service account and policies are ready,
  # otherwise the task may run and generate errors.
  depends_on = [
    sysdig_secure_cloud_account.cloud_account,
    google_service_account_iam_binding.sa_viewer_binding, # Depends on the service_account implicitly
    google_service_account_iam_binding.sa_custom_binding,
    google_iam_workload_identity_pool_provider.pool_provider, # Depends on the workload identity pool implicitly
  ]
}

###################################################
# Create Service Account and setup permissions
###################################################

resource "google_service_account" "sa" {
  project = var.project_id

  account_id   = "${var.naming_prefix}_cloudbench"
  display_name = "Service account for cloud-bench"
}

resource "google_project_iam_member" "viewer" {
  project = var.project_id

  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_custom_role" "custom" {
  project = var.project_id

  role_id     = "${var.naming_prefix}_cloudbench"
  title       = "Sysdig Cloud Benchmark Role"
  description = "A Role providing the required permissions for Sysdig Cloud Benchmarks that are not included in roles/viewer"
  permissions = ["storage.buckets.getIamPolicy"]
}

resource "google_service_account_iam_binding" "sa_custom_binding" {
  service_account_id = google_service_account.sa.name
  role               = google_project_iam_custom_role.custom.id

  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}",
  ]
}

resource "google_service_account_iam_binding" "sa_viewer_binding" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}",
  ]
}


###################################################
# Configure Workload Identity Federation
# See https://cloud.google.com/iam/docs/access-resources-aws
###################################################

resource "google_iam_workload_identity_pool" "pool" {
  project = var.project_id

  provider                  = google-beta
  workload_identity_pool_id = "${var.naming_prefix}-pool"
}

resource "google_iam_workload_identity_pool_provider" "pool_provider" {
  project = var.project_id

  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.naming_prefix}-pool-provider"
  display_name                       = "${var.naming_prefix}-pool-provider"
  description                        = "Sysdig Secure for Cloud"
  disabled                           = false

  aws {
    account_id = data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id
  }
}
