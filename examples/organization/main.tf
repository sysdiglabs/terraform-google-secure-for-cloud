locals {
  verify_ssl             = length(regexall("^https://.*?\\.sysdig.com/?", data.sysdig_secure_connection.current.secure_url)) != 0
  connector_filter       = <<EOT
  logName=~"/logs/cloudaudit.googleapis.com%2Factivity$" AND -resource.type="k8s_cluster"
EOT
  repository_project_ids = var.deploy_scanning ? length(var.repository_project_ids) == 0 ? [for p in data.google_projects.all_projects.projects : p.project_id] : var.repository_project_ids : []
}

data "google_organization" "org" {
  domain = var.organization_domain
}

data "google_projects" "all_projects" {
  filter = "parent.id:${data.google_organization.org.org_id} parent.type:organization lifecycleState:ACTIVE"
}


resource "google_service_account" "connector_sa" {
  account_id   = "${var.name}-cloudconnector"
  display_name = "Service account for cloud-connector"
}


#######################
#      CONNECTOR      #
#######################
module "connector_organization_sink" {
  source = "../../modules/infrastructure/organization_sink"

  organization_id = data.google_organization.org.org_id
  name            = "${var.name}-cloudconnector"
  filter          = local.connector_filter
}

resource "google_organization_iam_custom_role" "org_gcr_image_puller" {
  org_id = data.google_organization.org.org_id

  role_id     = "${var.name}_gcr_image_puller"
  title       = "Sysdig GCR Image Puller"
  description = "Allows pulling GCR images from all accounts in the organization"
  permissions = [
    "storage.objects.get",
    "storage.objects.list",
    "artifactregistry.repositories.get",
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.tags.list",
    "artifactregistry.tags.get",
    "run.services.get"
  ]
}

resource "google_organization_iam_member" "organization_image_puller" {
  org_id = data.google_organization.org.org_id

  role   = google_organization_iam_custom_role.org_gcr_image_puller.id
  member = "serviceAccount:${google_service_account.connector_sa.email}"
}

module "secure_secrets" {
  source = "../../modules/infrastructure/secrets"

  cloud_scanning_sa_email = google_service_account.connector_sa.email
  sysdig_secure_api_token = data.sysdig_secure_connection.current.secure_api_token
  name                    = var.name
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"

  cloud_connector_sa_email   = google_service_account.connector_sa.email
  sysdig_secure_endpoint     = data.sysdig_secure_connection.current.secure_url
  sysdig_secure_api_token    = data.sysdig_secure_connection.current.secure_api_token
  connector_pubsub_topic_id  = module.connector_organization_sink.pubsub_topic_id
  secure_api_token_secret_id = module.secure_secrets.secure_api_token_secret_name
  max_instances              = var.max_instances
  project_id                 = data.google_client_config.current.project

  #defaults
  name              = "${var.name}-cloudconnector"
  verify_ssl        = local.verify_ssl
  is_organizational = true

  deploy_scanning = var.deploy_scanning
}

#--------------------
# scanning
#--------------------

module "cloud_build_permission" {
  count  = var.deploy_scanning ? 1 : 0
  source = "../../modules/infrastructure/cloud_build_permission"

  cloud_connector_sa_email = google_service_account.connector_sa.email
  project_id               = data.google_client_config.current.project
}


module "pubsub_http_subscription" {
  for_each = toset(local.repository_project_ids)
  source   = "../../modules/infrastructure/pubsub_subscription"

  topic_project_id        = each.key
  subscription_project_id = data.google_client_config.current.project
  gcr_topic_name          = "gcr"
  name                    = "${var.name}-gcr"
  service_account_email   = google_service_account.connector_sa.email

  push_http_endpoint = "${module.cloud_connector.cloud_run_service_url}/gcr_scanning"
  push_to_cloudrun   = true
  deploy_scanning    = var.deploy_scanning
}


#--------------------
# benchmark
#--------------------

locals {
  benchmark_projects_ids = length(var.benchmark_project_ids) == 0 ? [for p in data.google_projects.all_projects.projects : p.project_id] : var.benchmark_project_ids
}

module "cloud_bench" {
  providers = {
    google      = google.multiproject
    google-beta = google-beta.multiproject
  }

  count  = var.deploy_benchmark ? 1 : 0
  source = "../../modules/services/cloud-bench"

  is_organizational   = true
  organization_domain = var.organization_domain
  role_name           = var.benchmark_role_name
  regions             = var.benchmark_regions
  project_ids         = local.benchmark_projects_ids
}
