locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  connector_filter = <<EOT
  logName=~"/logs/cloudaudit.googleapis.com%2Factivity$" AND -resource.type="k8s_cluster"
EOT
  scanning_filter  = <<EOT
  protoPayload.methodName = "google.cloud.run.v1.Services.CreateService" OR protoPayload.methodName = "google.cloud.run.v1.Services.ReplaceService"
EOT
}

provider "google" {
  region = var.location
}

provider "google-beta" {
  region = var.location
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = !local.verify_ssl
}

data "google_organization" "org" {
  domain = var.organization_domain
}

data "google_project" "project" {
}

data "google_projects" "all_projects" {
  filter = "parent.id:${data.google_organization.org.org_id} parent.type:organization lifecycleState:ACTIVE"
}

#######################
#      CONNECTOR      #
#######################
resource "google_service_account" "connector_sa" {
  account_id   = "${var.naming_prefix}-connector"
  display_name = "Service account for cloud-connector"
}

module "connector_organization_sink" {
  source = "../../modules/infrastructure/organization_sink"

  organization_id = data.google_organization.org.org_id
  naming_prefix   = "${var.naming_prefix}-connector"
  filter          = local.connector_filter
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"

  cloud_connector_sa_email  = google_service_account.connector_sa.email
  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  connector_pubsub_topic_id = module.connector_organization_sink.pubsub_topic_id
  max_instances             = var.max_instances
  project_id                = data.google_project.project.id

  #defaults
  naming_prefix = var.naming_prefix
  verify_ssl    = local.verify_ssl
}

#######################
#       SCANNING      #
#######################
resource "google_service_account" "scanning_sa" {
  account_id   = "${var.naming_prefix}-scanning"
  display_name = "Service account for cloud-scanning"
}


resource "google_organization_iam_custom_role" "org_gcr_image_puller" {
  org_id = data.google_organization.org.org_id

  role_id     = "${var.naming_prefix}_gcr_image_puller"
  title       = "Sysdig GCR Image Puller"
  description = "Allows pulling GCR images from all accounts in the organization"
  permissions = ["storage.objects.get", "storage.objects.list"]
}

resource "google_organization_iam_member" "organization_image_puller" {
  org_id = data.google_organization.org.org_id

  role   = google_organization_iam_custom_role.org_gcr_image_puller.id
  member = "serviceAccount:${google_service_account.scanning_sa.email}"
}

module "scanning_organization_sink" {
  source = "../../modules/infrastructure/organization_sink"

  organization_id = data.google_organization.org.org_id
  naming_prefix   = "${var.naming_prefix}-scanning"
  filter          = local.scanning_filter
}

module "secure_secrets" {
  source = "../../modules/infrastructure/secrets"

  cloud_scanning_sa_email = google_service_account.scanning_sa.email
  sysdig_secure_api_token = var.sysdig_secure_api_token
  naming_prefix           = var.naming_prefix
}

module "cloud_scanning" {
  source = "../../modules/services/cloud-scanning"

  naming_prefix              = var.naming_prefix
  secure_api_token_secret_id = module.secure_secrets.secure_api_token_secret_name
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_endpoint     = var.sysdig_secure_endpoint
  verify_ssl                 = local.verify_ssl

  cloud_scanning_sa_email  = google_service_account.scanning_sa.email
  create_gcr_topic         = var.create_gcr_topic
  scanning_pubsub_topic_id = module.connector_organization_sink.pubsub_topic_id
  project_id               = data.google_project.project.id

  max_instances = var.max_instances
}

#######################
#      BENCHMARKS     #
#######################
locals {
  benchmark_projects_ids = length(var.benchmark_project_ids) == 0 ? [for p in data.google_projects.all_projects.projects : p.project_id] : var.benchmark_project_ids
}

module "cloud_bench" {
  source            = "../../modules/services/cloud-bench"
  is_organizational = true
  role_name         = var.role_name
  project_id        = var.project_id
  regions           = var.regions
}
