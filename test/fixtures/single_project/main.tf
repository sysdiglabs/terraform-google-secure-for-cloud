module "sfc_example_single_project" {
  source = "../../../examples/single-project"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  project_id              = var.project_id
}
