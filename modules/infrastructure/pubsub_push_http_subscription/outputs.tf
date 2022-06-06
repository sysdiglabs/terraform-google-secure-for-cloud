output "auditlog_pubsub_subscription_name" {
  value       = google_pubsub_subscription.cloud_run_gcr_subscription.*.name
  description = "PubSub subscription for Auditlog"
}

output "gcr_pubsub_subscription_name" {
  value       = google_pubsub_subscription.k8s_gcr_subscription.*.name
  description = "PubSub subscription for GCR"
}
