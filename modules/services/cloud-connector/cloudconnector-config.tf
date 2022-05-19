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

  default_config_without_scanning = yamlencode({
    rules     = []
    notifiers = []
    ingestors = [
      {
        gcp-auditlog-pubsub-http = {
          url     = "/audit"
          project = data.google_project.project.project_id
        }
      }
    ]
  })

  config_content = var.deploy_scanning ? local.default_config : local.default_config_without_scanning
}
