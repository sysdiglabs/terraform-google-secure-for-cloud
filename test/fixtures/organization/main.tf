resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

module "sfc_example_organization" {
  source = "../../../examples/organization"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint

  organization_domain    = var.organization_domain
  name                   = "sfc${random_string.random.result}"
  project_id             = var.project_id
  repository_project_ids = [var.project_id]
  deploy_bench           = false
}
