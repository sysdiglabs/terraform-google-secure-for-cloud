locals {
  verify_ssl = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
}

module "cloud_connector" {
  count = var.cloudconnector_deploy ? 1 : 0

  source = "./modules/cloud-connector"

  location                = var.location
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  verify_ssl              = local.verify_ssl
  naming_prefix           = var.naming_prefix
}

module "cloud_scanning" {
  count  = var.cloudscanning_deploy ? 1 : 0
  source = "./modules/cloud-scanning"

  location                = var.location
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  verify_ssl              = local.verify_ssl
  naming_prefix           = var.naming_prefix
  create_gcr_topic        = var.create_gcr_topic
}
