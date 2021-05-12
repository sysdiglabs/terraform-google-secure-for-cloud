provider "google" {
  project = var.project_name
}

locals {
  deploy_cloudconnector = var.cloudconnector_deploy
  deploy_cloudscanning  = var.gcr_image_scanning_deploy || var.cloudrun_image_scanning_deploy
  deploy_cloudbench     = var.cloudbench_deploy
  verify_ssl            = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  bucket_name           = "${substr(lower(var.naming_prefix), 0, 29)}-config"
}

module "cloud-connector" {
  count = local.deploy_cloudconnector ? 1 : 0

  source = "../cloud-connector"

  naming_prefix           = var.naming_prefix
  location                = var.location
  bucket_config_name      = local.bucket_name
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  verify_ssl              = local.verify_ssl
  config_content          = <<EOF
rules:
  - secure:
      url: ${var.sysdig_secure_endpoint}
ingestors:
  - auditlog:
      project: ${var.project_name}
      interval: 30s
notifiers:
  - secure:
      url: ${var.sysdig_secure_endpoint}
  EOF
}

module "cloud-scanning" {
  count = local.deploy_cloudscanning ? 1 : 0

  source = "../cloud-scanning"

  naming_prefix           = var.naming_prefix
  project_name            = var.project_name
  location                = var.location
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint

  verify_ssl      = local.verify_ssl
  deploy_gcr      = var.gcr_image_scanning_deploy
  deploy_cloudrun = var.cloudrun_image_scanning_deploy
}
