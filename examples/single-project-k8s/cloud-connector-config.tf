locals {
  connector_config = {
    logging = "info"
    rules   = []
    ingestors = [
      {
        gcp-auditlog-pubsub = {
          project      = data.google_client_config.current.project
          subscription = module.pubsub_http_subscription.auditlog_pubsub_subscription_name
        },
      },
      {
        gcp-gcr-pubsub = {
          subscription = google_pubsub_subscription.gcr_subscription.name
          project      = module.pubsub_http_subscription.gcr_pubsub_subscription_name
        }
      }
    ]
    notifiers      = []
    gcpCredentials = jsonencode(jsondecode(base64decode(google_service_account_key.connector_sa_key.private_key)))
    scanners = var.deploy_scanning ? concat(
      [
        {
          gcp-gcr = {
            project                  = data.google_client_config.current.project
            secureAPITokenSecretName = module.secure_secrets.secure_api_token_secret_name
            serviceAccount           = google_service_account.connector_sa.email
          }
        }
      ],
      [
        {
          gcp-cloud-run = {
            project                  = data.google_client_config.current.project
            secureAPITokenSecretName = module.secure_secrets.secure_api_token_secret_name
            serviceAccount           = google_service_account.connector_sa.email
          }
        }
      ]
    ) : []
  }
}
