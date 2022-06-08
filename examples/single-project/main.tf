locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", data.sysdig_secure_connection.current.secure_url)) != 0
  connector_filter = <<EOT
  logName=~"^projects/${data.google_client_config.current.project}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
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

module "secure_secrets" {
  source = "../../modules/infrastructure/secrets"
  name   = "${var.name}-cloudconnector"

  cloud_scanning_sa_email = google_service_account.connector_sa.email
  sysdig_secure_api_token = data.sysdig_secure_connection.current.secure_api_token
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"
  name   = "${var.name}-cloudconnector"

  sysdig_secure_endpoint  = data.sysdig_secure_connection.current.secure_url
  sysdig_secure_api_token = data.sysdig_secure_connection.current.secure_api_token
  verify_ssl              = local.verify_ssl

  project_id                 = data.google_client_config.current.project
  cloud_connector_sa_email   = google_service_account.connector_sa.email
  connector_pubsub_topic_id  = module.connector_project_sink.pubsub_topic_id
  secure_api_token_secret_id = module.secure_secrets.secure_api_token_secret_name

  deploy_scanning = var.deploy_scanning
}

#######################
#      SCANNER       #
#######################
module "cloud_build_permission" {
  count  = var.deploy_scanning ? 1 : 0
  source = "../../modules/infrastructure/cloud_build_permission"


  cloud_connector_sa_email = google_service_account.connector_sa.email
  project_id               = data.google_client_config.current.project
}

module "pubsub_http_subscription" {
  source = "../../modules/infrastructure/pubsub_subscription"

  topic_project_id        = data.google_client_config.current.project
  subscription_project_id = data.google_client_config.current.project
  gcr_topic_name          = "gcr"
  name                    = "${var.name}-gcr"
  service_account_email   = google_service_account.connector_sa.email

  push_http_endpoint = "${module.cloud_connector.cloud_run_service_url}/gcr_scanning"
  push_to_cloudrun   = "true"
  deploy_scanning    = var.deploy_scanning
}
