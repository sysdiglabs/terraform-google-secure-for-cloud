resource "google_pubsub_topic" "trigger-topic" {
  name    = "trigger-event-topic"
  project = var.project_id
}

resource "google_logging_project_sink" "project_sink" {
  project                = google_pubsub_topic.trigger-topic.project
  name                   = "trigger-event-project-sink"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.trigger-topic.id}"
  unique_writer_identity = true
  filter                 = "resource.type = gce_instance AND severity >= WARNING"
}

resource "google_pubsub_topic_iam_member" "writer" {
  project = google_pubsub_topic.trigger-topic.project
  topic   = google_pubsub_topic.trigger-topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.project_sink.writer_identity
}
