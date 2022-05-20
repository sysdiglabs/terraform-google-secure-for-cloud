# Required to execute cloud build runs with this same service account
resource "google_project_iam_member" "service_account_user_itself" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.cloud_connector_sa_email}"
}

resource "google_project_iam_member" "builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${var.cloud_connector_sa_email}"
}
