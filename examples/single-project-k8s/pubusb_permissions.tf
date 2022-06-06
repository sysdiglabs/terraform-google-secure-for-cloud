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

resource "google_pubsub_subscription" "gcr_subscription" {
  name    = "${var.name}-${data.google_client_config.current.project}"
  topic   = "projects/${data.google_client_config.current.project}/topics/gcr"
  project = data.google_client_config.current.project

  labels = {
    product = "sysdig-secure-for-cloud"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = false
  ack_deadline_seconds       = 20

  expiration_policy {
    ttl = "300000.5s"
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "300s"
  }

  enable_message_ordering = false
  depends_on = [module.pubsub_http_subscription]
}
