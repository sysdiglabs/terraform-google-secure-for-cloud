output "k8s_auditlog_pubsub_subscription_name" {
  value       = length(google_pubsub_subscription.k8s_auditlog_subscription) > 0 ? google_pubsub_subscription.k8s_auditlog_subscription[0].name : "NA"
  description = "PubSub subscription for Auditlog events for K8s"
}

output "gcr_pubsub_subscription_name" {
  value       = google_pubsub_subscription.gcr_subscription.name
  description = "PubSub subscription for GCR events for K8s"
}
