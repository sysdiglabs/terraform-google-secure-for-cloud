locals {
  deploy_cloudconnector = var.cloudconnector_deploy
  verify_ssl            = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
}

data "google_project" "project" {
}

module "cloud_connector" {
  count = local.deploy_cloudconnector ? 1 : 0

  source = "./modules/cloud-connector"

  location                = var.location
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  verify_ssl              = local.verify_ssl
}
