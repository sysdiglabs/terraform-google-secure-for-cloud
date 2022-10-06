resource "google_service_account" "connector_sa" {
  account_id   = "${var.name}-cloudconnector"
  display_name = "Service account for cloud-connector"
}

resource "google_service_account_key" "connector_sa_key" {
  service_account_id = google_service_account.connector_sa.name
}

resource "google_project_iam_member" "event_receiver" {
  project = data.google_client_config.current.project
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.connector_sa.email}"
}

resource "google_project_iam_member" "token_creator" {
  # AC_GCP_0006
  # Why: Image scanning is run from inside a container. As it needs to get the image from the registry it needs a token to get it from the registry.
  # How to avoid security issues: As in the next implementation scanning will be run from within cloudrun which has needed permissions and won't need a token.
  # Warning: Organization users musn't be able to impersonate as the created service account.
  #ts:skip=AC_GCP_0006 Image scanning is run from inside a container. As it needs to get the image from the registry it needs a token to get it from the registry.
  project = data.google_client_config.current.project
  member  = "serviceAccount:${google_service_account.connector_sa.email}"
  role    = "roles/iam.serviceAccountTokenCreator"
}
