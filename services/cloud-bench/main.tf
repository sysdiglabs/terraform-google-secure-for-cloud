###################################################
# Fetch & compute required data
###################################################

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

data "google_project" "project" {
}

data "google_compute_regions" "regions" {
}

locals {
  regions = length(var.regions) == 0 ? data.google_compute_regions.regions.names : var.regions
}

###################################################
# Configure Sysdig Backend
###################################################

resource "sysdig_secure_cloud_account" "cloud_account" {
  account_id     = data.google_project.project.number
  alias          = data.google_project.project.name
  cloud_provider = "gcp"
  role_enabled   = "true"
}

resource "sysdig_secure_benchmark_task" "benchmark_task" {
  name     = "Sysdig Secure for Cloud (GCP) - ${data.google_project.project.name}"
  schedule = "0 6 * * *"
  schema   = "gcp_foundations_bench-1.2.0"
  scope    = "gcp.projectId = \"${data.google_project.project.number}\" and gcp.region in (\"${join("\", \"", local.regions)}\")"

  # Creation of a task requires that the Cloud Account already exists in the backend, and has `role_enabled = true`
  depends_on = [sysdig_secure_cloud_account.cloud_account]
}


###################################################
# Enable required APIs
###################################################

resource "google_project_service" "enable_iam_api" {
  project = data.google_project.project.id
  service = "iam.googleapis.com"
}

resource "google_project_service" "enable_service_account_credentials_api" {
  project = data.google_project.project.id
  service = "iamcredentials.googleapis.com"
}

resource "google_project_service" "enable_resource_manager_api" {
  project = data.google_project.project.id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "enable_sts_api" {
  project = data.google_project.project.id
  service = "sts.googleapis.com"
}


###################################################
# Create Service Account and setup permissions
###################################################

resource "google_service_account" "sa" {
  account_id   = "sysdigcloudbench"
  display_name = "Service account for cloud-bench"
}

resource "google_project_iam_member" "viewer" {
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_service_account_iam_binding" "sa_iam_binding" {
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
  provider                  = google-beta
  workload_identity_pool_id = "sysdigcloud"
}

resource "google_iam_workload_identity_pool_provider" "pool_provider" {
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdigcloud"
  display_name                       = "Sysdigcloud"
  description                        = "Sysdig Secure for Cloud"
  disabled                           = false

  aws {
    account_id = data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id
  }
}
