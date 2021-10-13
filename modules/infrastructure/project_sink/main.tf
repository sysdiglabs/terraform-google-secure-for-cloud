resource "google_pubsub_topic" "topic" {
  name = "${var.name}-topic"
}

resource "google_logging_project_sink" "project_sink" {
  name                   = "${var.name}-project-sink"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  unique_writer_identity = true
  filter                 = var.filter
}

resource "google_pubsub_topic_iam_member" "writer" {
  project = google_pubsub_topic.topic.project
  topic   = google_pubsub_topic.topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.project_sink.writer_identity
}
