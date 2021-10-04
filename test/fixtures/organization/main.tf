resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

module "sfc_example_single_project" {
  source = "../../../examples/organization"

  organization_domain     = var.organization_domain
  project_id              = var.project_id
  sysdig_secure_api_token = var.sysdig_secure_api_token
  create_gcr_topic        = false
  naming_prefix           = "sfc${random_string.random.result}"
  #  create_gcr_topic        = false
}