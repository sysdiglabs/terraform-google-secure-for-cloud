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
