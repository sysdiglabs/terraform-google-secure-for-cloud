locals {
  scanning_with_standalone_scanner = var.deploy_scanning && var.use_standalone_scanner
  connector_config = {
    logging = "info"
    rules   = []
    ingestors = [
      {
        gcp-auditlog-pubsub = {
          project      = data.google_client_config.current.project
          subscription = module.pubsub_http_subscription.k8s_auditlog_pubsub_subscription_name
        },
      },
      var.deploy_scanning ?
      {
        gcp-gcr-pubsub = {
          project      = data.google_client_config.current.project
          subscription = module.pubsub_http_subscription.gcr_pubsub_subscription_name
        }
      } : {}
    ]
    notifiers      = []
    gcpCredentials = jsonencode(jsondecode(base64decode(google_service_account_key.connector_sa_key.private_key)))
    scanners = var.deploy_scanning ? concat(
      [
        local.scanning_with_standalone_scanner ? {} : {
          gcp-gcr = {
            project                  = data.google_client_config.current.project
            secureAPITokenSecretName = module.secure_secrets.secure_api_token_secret_name
            serviceAccount           = google_service_account.connector_sa.email
          }
        }
      ],
      [
        local.scanning_with_standalone_scanner ? {} : {
          gcp-cloud-run = {
            project                  = data.google_client_config.current.project
            secureAPITokenSecretName = module.secure_secrets.secure_api_token_secret_name
            serviceAccount           = google_service_account.connector_sa.email
          }
        }
      ],
      [
        local.scanning_with_standalone_scanner ? {
          gcp-gcr-inline       = {},
          gcp-cloud-run-inline = {},
        } : {}
      ]
    ) : []
  }
}
