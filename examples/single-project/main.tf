locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  scanning_filter  = <<EOT
  protoPayload.methodName = "google.cloud.run.v1.Services.CreateService" OR protoPayload.methodName = "google.cloud.run.v1.Services.ReplaceService"
EOT
  connector_filter = <<EOT
  logName=~"^projects/${data.google_project.project.project_id}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
EOT
}

data "google_project" "project" {
}


#######################
#      CONNECTOR      #
#######################
provider "google" {
  project = var.project_name
}

resource "google_service_account" "connector_sa" {
  account_id   = "${var.naming_prefix}-cloud-connector"
  display_name = "Service account for cloud-connector"
}

module "connector_project_sinl" {
  source        = "../../infrastructure/project_sink"
  naming_prefix = var.naming_prefix
  filter        = local.connector_filter
  service       = "connector"
}

module "cloud_connector" {
  source = "../../services/cloud-connector"

  cloud_connector_sa_email  = google_service_account.connector_sa.email
  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  connector_pubsub_topic_id = module.connector_project_sinl.pubsub_topic_id

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

module "scanning_project_sink" {
  source        = "../../infrastructure/project_sink"
  naming_prefix = var.naming_prefix
  filter        = local.scanning_filter
  service       = "scanning"
}

# disable for testing purpose
module "cloud_scanning" {
  source = "../../services/cloud-scanning"

  cloud_scanning_sa_email  = google_service_account.scanning_sa.email
  scanning_pubsub_topic_id = module.scanning_project_sink.pubsub_topic_id
  create_gcr_topic         = var.create_gcr_topic

  secure_api_token_secret_id = module.secure_secrets.secure_api_token_secret_name
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_endpoint     = var.sysdig_secure_endpoint

  #defaults
  naming_prefix = var.naming_prefix
  verify_ssl    = local.verify_ssl
}
