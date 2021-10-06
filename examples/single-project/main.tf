locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  scanning_filter  = <<EOT
  protoPayload.methodName = "google.cloud.run.v1.Services.CreateService" OR protoPayload.methodName = "google.cloud.run.v1.Services.ReplaceService"
EOT
  connector_filter = <<EOT
  logName=~"^projects/${data.google_project.project.id}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
EOT
}

provider "google" {
  region = var.location
}

provider "google-beta" {
  region = var.location
}

data "google_project" "project" {
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = !local.verify_ssl
}

#######################
#      CONNECTOR      #
#######################
resource "google_service_account" "connector_sa" {
  account_id   = "${var.naming_prefix}-cloud-connector"
  display_name = "Service account for cloud-connector"
}


module "connector_project_sink" {
  source        = "../../modules/infrastructure/project_sink"
  naming_prefix = "${var.naming_prefix}-cloud-connector"
  filter        = local.connector_filter
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"


  cloud_connector_sa_email  = google_service_account.connector_sa.email
  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  connector_pubsub_topic_id = module.connector_project_sink.pubsub_topic_id
  project_id                = data.google_project.project.id

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
  source = "../../modules/infrastructure/secrets"

  cloud_scanning_sa_email = google_service_account.scanning_sa.email
  sysdig_secure_api_token = var.sysdig_secure_api_token
  naming_prefix           = var.naming_prefix
}

module "scanning_project_sink" {
  source        = "../../modules/infrastructure/project_sink"
  naming_prefix = "${var.naming_prefix}-cloud-scanning"
  filter        = local.scanning_filter
}

# disable for testing purpose
module "cloud_scanning" {
  source = "../../modules/services/cloud-scanning"

  cloud_scanning_sa_email  = google_service_account.scanning_sa.email
  scanning_pubsub_topic_id = module.scanning_project_sink.pubsub_topic_id
  create_gcr_topic         = var.create_gcr_topic
  project_id               = data.google_project.project.id

  secure_api_token_secret_id = module.secure_secrets.secure_api_token_secret_name
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_endpoint     = var.sysdig_secure_endpoint

  #defaults
  naming_prefix = var.naming_prefix
  verify_ssl    = local.verify_ssl
}


#######################
#      BENCHMARKS     #
#######################
module "cloud_bench" {
  source = "../../modules/services/cloud-bench"

  naming_prefix = var.naming_prefix
}
