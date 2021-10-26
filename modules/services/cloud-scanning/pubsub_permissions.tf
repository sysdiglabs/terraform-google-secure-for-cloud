resource "google_project_iam_member" "token_creator" {
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  role   = "roles/iam.serviceAccountTokenCreator"
}
