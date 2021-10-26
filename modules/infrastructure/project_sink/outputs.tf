output "pubsub_topic_id" {
  value       = google_pubsub_topic.topic.id
  description = "Cloud Connector PubSub single account topic id"
}

output "pubsub_topic_name" {
  value       = google_pubsub_topic.topic.name
  description = "Cloud Connector PubSub single account topic name"
}
