provider "google" {
  project = var.project_id
  region  = var.location
}

provider "google-beta" {
  project = var.project_id
  region  = var.location
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = !local.verify_ssl
}

locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  scanning_filter  = <<EOT
  protoPayload.methodName = "google.cloud.run.v1.Services.CreateService" OR protoPayload.methodName = "google.cloud.run.v1.Services.ReplaceService"
EOT
  connector_filter = <<EOT
  logName=~"^projects/${var.project_id}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
EOT
}


#######################
#      CONNECTOR      #
#######################
resource "google_service_account" "connector_sa" {
  account_id   = "${var.name}-cloudconnector"
  display_name = "Service account for cloud-connector"
}


module "connector_project_sink" {
  source = "../../modules/infrastructure/project_sink"
  name   = "${var.name}-cloudconnector"
  filter = local.connector_filter
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"


  cloud_connector_sa_email  = google_service_account.connector_sa.email
  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  connector_pubsub_topic_id = module.connector_project_sink.pubsub_topic_id
  project_id                = var.project_id

  #defaults
  name       = "${var.name}-cloudconnector"
  verify_ssl = local.verify_ssl
}


#######################
#       SCANNING      #
#######################
resource "google_service_account" "scanning_sa" {
  account_id   = "${var.name}-cloudscanning"
  display_name = "Service account for cloud-scanning"
}

module "secure_secrets" {
  source = "../../modules/infrastructure/secrets"

  cloud_scanning_sa_email = google_service_account.scanning_sa.email
  sysdig_secure_api_token = var.sysdig_secure_api_token
  name                    = var.name
}

module "scanning_project_sink" {
  source = "../../modules/infrastructure/project_sink"
  name   = "${var.name}-cloudscanning"
  filter = local.scanning_filter
}

# disable for testing purpose
module "cloud_scanning" {
  source = "../../modules/services/cloud-scanning"

  cloud_scanning_sa_email  = google_service_account.scanning_sa.email
  scanning_pubsub_topic_id = module.scanning_project_sink.pubsub_topic_id
  create_gcr_topic         = var.create_gcr_topic
  project_id               = var.project_id

  secure_api_token_secret_id = module.secure_secrets.secure_api_token_secret_name
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_endpoint     = var.sysdig_secure_endpoint

  #defaults
  name       = var.name
  verify_ssl = local.verify_ssl
}


#######################
#      BENCHMARKS     #
#######################
module "cloud_bench" {
  count  = var.deploy_bench ? 1 : 0
  source = "../../modules/services/cloud-bench"

  is_organizational = false
  role_name         = var.role_name
  project_id        = var.project_id
  regions           = var.regions
}
