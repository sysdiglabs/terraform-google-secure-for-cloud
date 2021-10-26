data "google_pubsub_topic" "topic" {
  name    = var.topic_name
  project = var.topic_project_id
}

locals {
  create_topic = (data.google_pubsub_topic.topic.name == null || lookup(coalesce(data.google_pubsub_topic.topic.labels, {}), "sysdig-managed", "false") == "true")
}

resource "google_pubsub_topic" "topic" {
  count   = local.create_topic ? 1 : 0
  name    = var.topic_name
  project = var.topic_project_id
  labels = {
    sysdig-managed = "true"
  }
}

resource "google_pubsub_subscription" "subscription" {
  name    = "${var.name}-${var.topic_project_id}"
  topic   = "projects/${var.topic_project_id}/topics/${var.topic_name}"
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
