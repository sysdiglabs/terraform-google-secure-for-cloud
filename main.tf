locals {
  deploy_cloudconnector = var.cloudconnector_deploy
  verify_ssl            = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  bucket_name           = "${substr(lower(var.naming_prefix), 0, 29)}-config"
  naming_prefix         = var.naming_prefix == null ? data.google_project.project.project_id : var.naming_prefix
}

data "google_project" "project" {
}

module "cloud_connector" {
  count = local.deploy_cloudconnector ? 1 : 0

  source = "./modules/cloud-connector"

  naming_prefix           = local.naming_prefix
  location                = var.location
  bucket_config_name      = local.bucket_name
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  verify_ssl              = local.verify_ssl
}
