#FIXME: just use one data
data "google_project" "project" {
}

resource "google_pubsub_topic" "topic" {
  name = "${var.naming_prefix}-cloud-connector-topic"
}

resource "google_logging_project_sink" "project_sink" {
  #  depends_on             = [google_pubsub_topic.topic]
  name                   = "${var.naming_prefix}-cloud-connector-project-sink"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  unique_writer_identity = true
  filter                 = <<EOT
  logName=~"^projects/${data.google_project.project.project_id}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
EOT
}

resource "google_pubsub_topic_iam_member" "writer" {
  project = google_pubsub_topic.topic.project
  topic   = google_pubsub_topic.topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.project_sink.writer_identity
}
