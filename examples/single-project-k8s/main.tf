locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", data.sysdig_secure_connection.current.secure_url)) != 0
  connector_filter = <<EOT
  logName=~"^projects/${data.google_client_config.current.project}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
EOT
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
  pubsub_topic_name       = module.connector_project_sink.pubsub_topic_name
  deploy_scanning         = var.deploy_scanning
  push_to_cloudrun        = false
}
