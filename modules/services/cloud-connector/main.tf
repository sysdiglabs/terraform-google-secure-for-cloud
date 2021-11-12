# This lines are here because of pre-commit hook
locals {
  default_config = yamlencode({
    rules     = []
    notifiers = []
    ingestors = [
      {
        gcp-auditlog-pubsub-http = {
          url     = "/audit"
          project = data.google_project.project.project_id
        }
      },
      {
        gcp-gcr-pubsub-http = {
          url     = "/gcr_scanning"
          project = data.google_project.project.project_id
        }
      }
    ]
    scanners = [
      {
        gcp-gcr = {
          project                  = var.project_id
          secureAPITokenSecretName = var.secure_api_token_secret_id
          serviceAccount           = var.cloud_connector_sa_email
        }
      },
      {
        gcp-cloud-run = {
          project                  = var.project_id
          secureAPITokenSecretName = var.secure_api_token_secret_id
          serviceAccount           = var.cloud_connector_sa_email
        }
      }
    ]
  })
  config_content = var.config_content == null && var.config_source == null ? local.default_config : var.config_content
}

data "google_project" "project" {
  project_id = var.project_id
}
