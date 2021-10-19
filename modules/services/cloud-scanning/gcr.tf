locals {
  gcr_topic_id = var.create_gcr_topic ? google_pubsub_topic.gcr[0].id : data.google_pubsub_topic.gcr.id

  # note
  # topic name is hardcoded by GCP and cannot be changed
  # resource cannot honor var.name
  # https://cloud.google.com/container-registry/docs/configuring-notifications
  # https://cloud.google.com/artifact-registry/docs/configure-notifications
  gcr_topic_name = "gcr"
}

data "google_pubsub_topic" "gcr" {
  project = var.project_id

  name = local.gcr_topic_name
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
  name  = local.gcr_topic_name
}


resource "google_pubsub_subscription" "gcr" {
  for_each = toset(var.project_scan_ids)
  name     = "${var.name}-gcr-${each.key}"
  topic    = "projects/${each.key}/topics/${local.gcr_topic_name}"

  ack_deadline_seconds = 10

  push_config {
    push_endpoint = "${google_cloud_run_service.cloud_scanning.status.url}/gcr_scanning}"
    oidc_token {
      service_account_email = var.cloud_scanning_sa_email
    }
  }
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "300s"
  }
}

#new
/*
resource "google_eventarc_trigger" "gcr" {
  count = length(local.gcr_topic_id[*]) > 0 ? 1 : 0
  # We won't try to deploy this trigger if the GCR topic doesn't exist
  name            = "${var.name}-trigger-gcr"
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
*/
