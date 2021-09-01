locals {
  gcr_topic_id = var.create_gcr_topic ? google_pubsub_topic.gcr[0].id : data.google_pubsub_topic.gcr.id
}

data "google_pubsub_topic" "gcr" {
  name = "gcr"
  # MUST exist in the infra of the customer, that's the only topic GCR will publish events to.
}

# FIXME: is this the right place?
# Required to execute cloud build runs with this same service account
resource "google_project_iam_member" "service_account_user_itself" {
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${var.cloud_scanning_sa_email}"
}

resource "google_project_iam_member" "builder" {
  role   = "roles/cloudbuild.builds.builder"
  member = "serviceAccount:${var.cloud_scanning_sa_email}"
}

resource "google_pubsub_topic" "gcr" {
  count = var.create_gcr_topic ? 1 : 0
  name  = "gcr"
}

#new
resource "google_eventarc_trigger" "gcr" {
  count = length(local.gcr_topic_id[*]) > 0 ? 1 : 0
  # We won't try to deploy this trigger if the GCR topic doesn't exist
  name            = "${var.naming_prefix}-cloud-scanning-trigger-gcr"
  location        = var.location
  service_account = var.cloud_scanning_sa_email
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.cloud_scanning.name
      region  = var.location
      path    = "/gcr_scanning"
    }
  }
  transport {
    pubsub {
      topic = local.gcr_topic_id
    }
  }
}
