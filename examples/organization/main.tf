locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  connector_filter = <<EOT
  logName=~"/logs/cloudaudit.googleapis.com%2Factivity$" AND -resource.type="k8s_cluster"
EOT
  scanning_filter  = <<EOT
  protoPayload.methodName = "google.cloud.run.v1.Services.CreateService" OR protoPayload.methodName = "google.cloud.run.v1.Services.ReplaceService"
EOT
}

# This provider is project specific, and can only be used to provision resources in the
# specified project. Primarily used for Cloud Connector and Cloud Scanning
provider "google" {
  project = var.project_id
  region  = var.location
}

# This provider is project agnostic, and can be used to provision resources in any project,
# provided the project is specified on the resource. Primarily used for Benchmarks
provider "google" {
  alias  = "multiproject"
  region = var.location
}

# This provider is project agnostic, and can be used to provision resources in any project,
# provided the project is specified on the resource. Primarily used for Benchmarks
provider "google-beta" {
  alias  = "multiproject"
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

data "google_projects" "all_projects" {
  filter = "parent.id:${data.google_organization.org.org_id} parent.type:organization lifecycleState:ACTIVE"
}


#######################
#      CONNECTOR      #
#######################
resource "google_service_account" "connector_sa" {
  account_id   = "${var.name}-cloudconnector"
  display_name = "Service account for cloud-connector"
}

module "connector_organization_sink" {
  source = "../../modules/infrastructure/organization_sink"

  organization_id = data.google_organization.org.org_id
  name            = "${var.name}-cloudconnector"
  filter          = local.connector_filter
}

module "cloud_connector" {
  source = "../../modules/services/cloud-connector"

  cloud_connector_sa_email  = google_service_account.connector_sa.email
  sysdig_secure_api_token   = var.sysdig_secure_api_token
  sysdig_secure_endpoint    = var.sysdig_secure_endpoint
  connector_pubsub_topic_id = module.connector_organization_sink.pubsub_topic_id
  max_instances             = var.max_instances
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


resource "google_organization_iam_custom_role" "org_gcr_image_puller" {
  org_id = data.google_organization.org.org_id

  role_id     = "${var.name}_gcr_image_puller"
  title       = "Sysdig GCR Image Puller"
  description = "Allows pulling GCR images from all accounts in the organization"
  permissions = [
    "storage.objects.get",
    "storage.objects.list"
  ]
}

resource "google_organization_iam_member" "organization_image_puller" {
  org_id = data.google_organization.org.org_id

  role   = google_organization_iam_custom_role.org_gcr_image_puller.id
  member = "serviceAccount:${google_service_account.scanning_sa.email}"
}

module "scanning_organization_sink" {
  source = "../../modules/infrastructure/organization_sink"

  organization_id = data.google_organization.org.org_id
  name            = "${var.name}-cloudscanning"
  filter          = local.scanning_filter
}

module "secure_secrets" {
  source = "../../modules/infrastructure/secrets"

  cloud_scanning_sa_email = google_service_account.scanning_sa.email
  sysdig_secure_api_token = var.sysdig_secure_api_token
  name                    = var.name
}

data "google_projects" "my-org-projects" {
  filter = "parent.id:012345678910 lifecycleState:DELETE_REQUESTED"
}

module "cloud_scanning" {
  source = "../../modules/services/cloud-scanning"

  name                       = "${var.name}-cloudscanning"
  secure_api_token_secret_id = module.secure_secrets.secure_api_token_secret_name
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_endpoint     = var.sysdig_secure_endpoint
  verify_ssl                 = local.verify_ssl

  cloud_scanning_sa_email  = google_service_account.scanning_sa.email
  create_gcr_topic         = var.create_gcr_topic
  scanning_pubsub_topic_id = module.connector_organization_sink.pubsub_topic_id
  project_id               = var.project_id

  project_scan_ids = length(var.project_scan_ids) == 0 ? [var.project_id] : var.project_scan_ids

  max_instances = var.max_instances
}

#######################
#      BENCHMARKS     #
#######################

locals {
  benchmark_projects_ids = length(var.benchmark_project_ids) == 0 ? [for p in data.google_projects.all_projects.projects : p.project_id] : var.benchmark_project_ids
}

module "cloud_bench" {
  providers = {
    google      = google.multiproject
    google-beta = google-beta.multiproject
  }

  count  = var.deploy_bench ? 1 : 0
  source = "../../modules/services/cloud-bench"

  is_organizational   = true
  organization_domain = var.organization_domain
  role_name           = var.role_name
  regions             = var.benchmark_regions
  project_ids         = local.benchmark_projects_ids
}
