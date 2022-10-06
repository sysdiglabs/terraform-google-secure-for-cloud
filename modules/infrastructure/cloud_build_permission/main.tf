# Required to execute cloud build runs with this same service account
resource "google_project_iam_member" "service_account_user_itself" {
  # AC_GCP_0006
  # Why: Image scanning is run from inside a container. As it needs to get the image from the registry it needs a token to get it from the registry.
  # How to avoid security issues: As in the next implementation scanning will be run from within cloudrun which has needed permissions and won't need a token.
  # Warning: Organization users musn't be able to impersonate as the created service account.
  #ts:skip=AC_GCP_0006 Image scanning is run from inside a container. As it needs to get the image from the registry it needs a token to get it from the registry.
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.cloud_connector_sa_email}"
}

resource "google_project_iam_member" "builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${var.cloud_connector_sa_email}"
}
