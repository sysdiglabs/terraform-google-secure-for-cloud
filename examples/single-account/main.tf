locals {
  verify_ssl = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
}

#######################
#      CONNECTOR      #
#######################
provider "google" {
  project = var.project_name
  region  = var.location
}

resource "google_service_account" "connector_sa" {
  account_id   = "${var.naming_prefix}-cloud-connector"
  display_name = "Service account for cloud-connector"
}

module "connector_pubsub" {
  source        = "../../infrastructure/connector-single-sink"
  naming_prefix = var.naming_prefix
}

module "cloud_connector" {
  count  = var.cloud_connector_deploy ? 1 : 0
  source = "../../services/cloud-connector"

  cloud_connector_sa_email  = google_service_account.connector_sa.email
  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  connector_pubsub_topic_id = module.connector_pubsub.connector_pubsub_topic_id

  #defaults
  naming_prefix = var.naming_prefix
  verify_ssl    = local.verify_ssl
}


#######################
#       SCANNING      #
#######################

resource "google_service_account" "scanning_sa" {
  account_id   = "${var.naming_prefix}-cloud-scanning"
  display_name = "Service account for cloud-scanning"
}

module "secure_secrets" {
  source = "../../infrastructure/secrets"

  cloud_scanning_sa_email = google_service_account.scanning_sa.email
  sysdig_secure_api_token = var.sysdig_secure_api_token
  naming_prefix           = var.naming_prefix
}

module "scanning_pubsub" {
  source        = "../../infrastructure/scanning-single-sink"
  naming_prefix = var.naming_prefix
}

# disable for testing purpose
module "cloud_scanning" {
  count  = var.cloud_scanning_deploy ? 1 : 0
  source = "../../services/cloud-scanning"

  cloud_connector_sa_email = google_service_account.scanning_sa.email
  scanning_pubsub_topic_id = module.scanning_pubsub.scanning_pubsub_topic_id
  create_gcr_topic         = var.create_gcr_topic

  secure_api_token_secret_id = module.secure_secrets.secure_api_token_secret_id
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_endpoint     = var.sysdig_secure_endpoint

  #defaults
  naming_prefix = var.naming_prefix
  verify_ssl    = local.verify_ssl
}
