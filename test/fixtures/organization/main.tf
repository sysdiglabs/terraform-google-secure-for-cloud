resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

resource "google_pubsub_topic" "gcr" {
  project = var.project_id
  name    = "gcr"
}

module "sfc_example_organization" {
  source = "../../../examples/organization"

  organization_domain     = var.organization_domain
  sysdig_secure_api_token = var.sysdig_secure_api_token
  name                    = "sfc${random_string.random.result}"
  project_id              = var.project_id
  project_scan_ids        = [var.project_id]
  deploy_bench            = false
}
