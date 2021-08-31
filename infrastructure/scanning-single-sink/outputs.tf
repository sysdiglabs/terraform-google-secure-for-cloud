output "scanning_pubsub_topic_id" {
  value       = google_pubsub_topic.topic.id
  description = "Cloud Scanning PubSub single account topic id"
}
