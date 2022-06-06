data "google_pubsub_topic" "topic" {
  name    = var.gcr_topic_name
  project = var.topic_project_id
}

locals {
  create_topic = (data.google_pubsub_topic.topic.name == null || lookup(coalesce(data.google_pubsub_topic.topic.labels, {}), "sysdig-managed", "false") == "true")
}

resource "google_pubsub_topic" "topic" {
  count   = local.create_topic ? 1 : 0
  name    = var.gcr_topic_name
  project = var.topic_project_id
  labels  = {
    sysdig-managed = "true"
  }
}

resource "google_pubsub_subscription" "subscription" {
  count   = var.push_http_endpoint != "" ? 1 : 0
  name    = "${var.name}-${var.topic_project_id}"
  topic   = "projects/${var.topic_project_id}/topics/${var.gcr_topic_name}"
  project = var.subscription_project_id

  ack_deadline_seconds = 10

  push_config {
    push_endpoint = var.push_http_endpoint
    oidc_token {
      service_account_email = var.service_account_email
    }
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "300s"
  }
}

resource "google_pubsub_subscription" "gcr_subscription" {
  count   = var.push_http_endpoint == "" ? 1 : 0
  name    = "${var.name}-${var.topic_project_id}"
  topic   = "projects/${var.topic_project_id}/topics/${var.topic_project_id}"
  project = var.topic_project_id

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
}

resource "google_pubsub_subscription" "subscription" {
  name  = var.name
  topic = var.pubsub_topic_name

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
