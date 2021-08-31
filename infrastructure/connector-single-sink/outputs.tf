output "connector_pubsub_topic_id" {
  value       = google_pubsub_topic.topic.id
  description = "Cloud Connector PubSub single account topic id"
}
