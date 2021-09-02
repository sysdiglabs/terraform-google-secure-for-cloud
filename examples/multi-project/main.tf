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
  project_id = var.org_project_name
}

#######################
#      CONNECTOR      #
#######################
provider "google" {
  project = var.org_project_name
  region  = var.location
  alias   = "organization"
}

provider "google" {
  project = var.member_project_name
  region  = var.location
  alias   = "member"
}

resource "google_service_account" "connector_sa" {
  account_id   = "${var.naming_prefix}-cloud-connector"
  display_name = "Service account for cloud-connector"
}

module "connector_organization_sink" {
  providers = {
    google = google.organization
  }
  source = "../../infrastructure/organization_sink"

  organization_id = data.google_project.project.org_id
  naming_prefix   = var.naming_prefix
  filter          = local.connector_filter
  service         = "connector"
}

module "cloud_connector" {
  providers = {
    google = google.organization
  }
  source = "../../services/cloud-connector"

  cloud_connector_sa_email  = google_service_account.connector_sa.email
  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  connector_pubsub_topic_id = module.connector_organization_sink.pubsub_topic_id

  #defaults
  naming_prefix = var.naming_prefix
  verify_ssl    = local.verify_ssl
}
