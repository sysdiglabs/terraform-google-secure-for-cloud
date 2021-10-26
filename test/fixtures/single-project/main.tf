resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

module "sfc_example_single_project" {
  source = "../../../examples/single-project"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  name                    = "sfc${random_string.random.result}"
  project_id              = var.project_id
  deploy_bench            = false
}
