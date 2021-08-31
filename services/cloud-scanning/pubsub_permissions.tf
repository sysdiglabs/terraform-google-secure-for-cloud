resource "google_project_iam_member" "event_receiver" {
  role   = "roles/eventarc.eventReceiver"
  member = "serviceAccount:${var.cloud_connector_sa_email}"
}


resource "google_project_iam_member" "token_creator" {
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  role   = "roles/iam.serviceAccountTokenCreator"
}
