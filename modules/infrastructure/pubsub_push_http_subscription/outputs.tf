output "auditlog_pubsub_subscription_name" {
  value = google_pubsub_subscription.subscription.name
  description = "PubSub subscription for Auditlog"
}

output "gcr_pubsub_subscription_name" {
  value = google_pubsub_subscription.gcr_subscription.name
  description = "PubSub subscription for GCR"
}