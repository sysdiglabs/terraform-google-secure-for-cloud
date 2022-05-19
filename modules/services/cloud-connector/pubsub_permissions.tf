resource "google_project_iam_member" "event_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${var.cloud_connector_sa_email}"
}

resource "google_project_iam_member" "token_creator" {
  project = var.project_id
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  role    = "roles/iam.serviceAccountTokenCreator"
}
