locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  connector_filter = <<EOT
  logName=~"/logs/cloudaudit.googleapis.com%2Factivity$" AND -resource.type="k8s_cluster"
EOT
}

data "google_project" "project" {

}

data "google_projects" "all_projects" {
  filter = "parent.id:${var.org_id}"
}

#######################
#      CONNECTOR      #
#######################
provider "google" {
  project = var.org_project_name
  region  = var.location
}

resource "google_service_account" "connector_sa" {
  account_id   = "${var.naming_prefix}-cloud-connector"
  display_name = "Service account for cloud-connector"
}

module "connector_organization_sink" {
  source = "../../modules/infrastructure/organization_sink"

  organization_id = data.google_project.project.org_id
  naming_prefix   = var.naming_prefix
  filter          = local.connector_filter
  service         = "connector"
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"

  cloud_connector_sa_email  = google_service_account.connector_sa.email
  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  connector_pubsub_topic_id = module.connector_organization_sink.pubsub_topic_id
  max_instances             = var.max_instances

  #defaults
  naming_prefix = var.naming_prefix
  verify_ssl    = local.verify_ssl
}

#######################
#      BENCHMARKS     #
#######################

locals {
  benchmark_projects_ids = length(var.benchmark_project_ids) == 0 ? [for p in data.google_projects.all_projects.projects : p.project_id] : var.benchmark_project_ids
}

provider "google-beta" {
  project = var.org_project_name
  region  = var.location
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = !local.verify_ssl
}

module "cloud_bench" {
  for_each = toset(local.benchmark_projects_ids)
  source   = "../../modules/services/cloud-bench"

  project_id = each.key
}

