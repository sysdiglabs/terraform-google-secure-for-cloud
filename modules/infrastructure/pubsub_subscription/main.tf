data "google_pubsub_topic" "topic" {
  name    = var.gcr_topic_name
  project = var.topic_project_id
}

locals {
  create_topic = (data.google_pubsub_topic.topic.name == null || lookup(coalesce(data.google_pubsub_topic.topic.labels, {}), "sysdig-managed", "false") == "true")
}

resource "google_pubsub_topic" "topic" {
  count   = local.create_topic && var.deploy_scanning ? 1 : 0
  name    = var.gcr_topic_name
  project = var.topic_project_id
  labels = {
    sysdig-managed = "true"
  }
}

## Subscription for GCR events
## In case of CloudRun it will be a Push subscription
## In case of K8s it will be a simple subscription
resource "google_pubsub_subscription" "gcr_subscription" {
  count   = var.deploy_scanning ? 1 : 0
  name    = "${var.name}-${var.topic_project_id}"
  topic   = "projects/${var.topic_project_id}/topics/${var.gcr_topic_name}"
  project = var.subscription_project_id


  dynamic "push_config" {
    for_each = var.push_to_cloudrun ? [1] : []
    content {
      push_endpoint = var.push_http_endpoint
      oidc_token {
        service_account_email = var.service_account_email
      }
    }
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = false
  ack_deadline_seconds       = 10

  expiration_policy {
    ttl = "300000.5s"
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "300s"
  }

  enable_message_ordering = false
}

# Subscription to auditlog events for K8s
resource "google_pubsub_subscription" "k8s_auditlog_subscription" {
  count = var.push_to_cloudrun ? 0 : 1
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

resource "google_pubsub_subscription_iam_member" "k8s_auditlog_subscription" {
  count        = var.push_to_cloudrun ? 0 : 1
  subscription = google_pubsub_subscription.k8s_auditlog_subscription[0].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.service_account_email}"
}

resource "google_pubsub_subscription_iam_member" "gcr_subscription" {
  count        = var.deploy_scanning ? 1 : 0
  subscription = google_pubsub_subscription.gcr_subscription[0].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.service_account_email}"
}
