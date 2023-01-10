###################################################
# Fetch & compute required data
###################################################

locals {
  project_ids = var.project_ids
}

data "sysdig_secure_trusted_cloud_identity" "trusted_identity" {
  cloud_provider = "gcp"
}

data "google_project" "project" {
  project_id = var.project_id
}

data "google_organization" "org" {
  domain = var.organization_domain
}

###################################################
# Configure Sysdig Backend
###################################################

resource "sysdig_secure_cloud_account" "cloud_account" {
  for_each                     = toset(local.project_ids)
  account_id                   = var.project_id_number_map[each.key]
  alias                        = each.key
  cloud_provider               = "gcp"
  role_enabled                 = "true"
  role_name                    = var.role_name
  workload_identity_account_id = var.project_id_number_map[var.project_id]
}

###################################################
# Create Service Account and setup permissions
###################################################

resource "google_service_account" "sa" {
  project      = var.project_id
  account_id   = var.role_name
  display_name = "Service account for cloud-bench"
}

resource "google_organization_iam_member" "viewer" {
  org_id = data.google_organization.org.org_id
  role   = "roles/viewer"
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_organization_iam_member" "custom" {
  org_id = data.google_organization.org.org_id

  role   = google_organization_iam_custom_role.custom.id
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_organization_iam_custom_role" "custom" {
  org_id = data.google_organization.org.org_id

  role_id     = var.role_name
  title       = "Sysdig Cloud Benchmark Role"
  description = "A Role providing the required permissions for Sysdig Cloud Benchmarks that are not included in roles/viewer"
  permissions = ["storage.buckets.getIamPolicy", "bigquery.tables.list", "cloudasset.assets.listIamPolicy", "cloudasset.assets.listResource"]
}

resource "google_organization_iam_binding" "sa_pool_binding" {
  for_each = toset(local.project_ids)
  org_id   = data.google_organization.org.org_id
  role     = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.aws_role/arn:aws:sts::${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id}:assumed-role/${data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_role_name}/${sysdig_secure_cloud_account.cloud_account[each.key].external_id}",
  ]
}

###################################################
# Configure Workload Identity Federation
# See https://cloud.google.com/iam/docs/access-resources-aws
###################################################

resource "google_iam_workload_identity_pool" "pool" {
  project = var.project_id

  provider                  = google-beta
  workload_identity_pool_id = "sysdigcloud"
}

resource "google_iam_workload_identity_pool_provider" "pool_provider" {
  project = var.project_id

  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "sysdigcloud"
  display_name                       = "Sysdigcloud"
  description                        = "Sysdig Secure for Cloud"
  disabled                           = false

  aws {
    account_id = data.sysdig_secure_trusted_cloud_identity.trusted_identity.aws_account_id
  }

  attribute_mapping = {
    "google.subject" : "assertion.arn",
    "attribute.aws_role" : "assertion.arn"
  }

}
