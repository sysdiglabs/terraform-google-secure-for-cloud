resource "google_pubsub_topic" "topic" {
  name = "${var.naming_prefix}-cloud-scanning-topic"
}

resource "google_logging_project_sink" "project_sink" {
  name                   = "${var.naming_prefix}-cloud-scanning-project-sink"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  unique_writer_identity = true
  filter                 = <<EOT
  protoPayload.methodName = "google.cloud.run.v1.Services.CreateService" OR protoPayload.methodName = "google.cloud.run.v1.Services.ReplaceService"
EOT
}

resource "google_pubsub_topic_iam_member" "writer" {
  project = google_pubsub_topic.topic.project
  topic   = google_pubsub_topic.topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.project_sink.writer_identity
}
