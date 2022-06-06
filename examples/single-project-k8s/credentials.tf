resource "google_service_account" "connector_sa" {
  account_id   = "${var.name}-cloudconnector"
  display_name = "Service account for cloud-connector"
}

resource "google_service_account_key" "connector_sa_key" {
  service_account_id = google_service_account.connector_sa.name
}

resource "google_pubsub_subscription_iam_member" "pull" {
  subscription = google_pubsub_subscription.subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.connector_sa.email}"
}

resource "google_pubsub_subscription_iam_member" "pull_gcr" {
  subscription = google_pubsub_subscription.gcr_subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.connector_sa.email}"
}

resource "google_project_iam_member" "event_receiver" {
  project = data.google_client_config.current.project
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.connector_sa.email}"
}

resource "google_project_iam_member" "token_creator" {
  project = data.google_client_config.current.project
  member  = "serviceAccount:${google_service_account.connector_sa.email}"
  role    = "roles/iam.serviceAccountTokenCreator"
}
