resource "google_pubsub_topic" "topic" {
  name = "${var.naming_prefix}-topic"
}

resource "google_logging_organization_sink" "organization_sink" {
  name             = "${var.naming_prefix}-organization-sink"
  org_id           = var.organization_id
  destination      = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  include_children = true
  filter           = var.filter
}

resource "google_pubsub_topic_iam_member" "writer" {
  project = google_pubsub_topic.topic.project
  topic   = google_pubsub_topic.topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_organization_sink.organization_sink.writer_identity
}
