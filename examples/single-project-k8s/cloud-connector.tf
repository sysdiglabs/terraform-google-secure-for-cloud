module "connector_project_sink" {
  source = "../../modules/infrastructure/project_sink"
  name   = "${var.name}-cloudconnector"

  filter = local.connector_filter
}

resource "google_pubsub_subscription" "subscription" {
  name  = var.name
  topic = module.connector_project_sink.pubsub_topic_name

  labels = {
    product = "sysdig-secure-for-cloud"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = false

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering = false
}

resource "helm_release" "cloud_connector" {
  name = "cloud-connector"

  repository = "https://charts.sysdig.com"
  chart      = "cloud-connector"

  create_namespace = true
  namespace        = var.name
  atomic           = true
  timeout          = 60

  set_sensitive {
    name  = "sysdig.secureAPIToken"
    value = var.sysdig_secure_api_token
  }

  set {
    name  = "sysdig.url"
    value = var.sysdig_secure_endpoint
  }

  set {
    name  = "sysdig.verifySSL"
    value = local.verify_ssl
  }

  set {
    name  = "image.repository"
    value = var.cloud_connector_image
  }

  values = [
    <<EOF
rules: []
ingestors:
- gcp-auditlog-pubsub:
    project: ${data.google_client_config.current.project}
    subscription: ${google_pubsub_subscription.subscription.name}
notifiers: []
gcpCredentials: |
  ${jsonencode(jsondecode(base64decode(google_service_account_key.connector_sa_key.private_key)))}
EOF
  ]
}
