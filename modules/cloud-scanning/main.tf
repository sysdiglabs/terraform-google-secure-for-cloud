locals {
  task_env_vars = concat([
    {
      name  = "SECURE_URL"
      value = var.sysdig_secure_endpoint
    },
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "GCP_PROJECT"
      value = data.google_project.project.project_id
    },
    {
      name  = "GCP_SERVICE_ACCOUNT"
      value = google_service_account.sa.email
    },
    {
      name  = "SECURE_API_TOKEN_SECRET"
      value = google_secret_manager_secret.secure_api_secret.secret_id
    }
    ], [for env_key, env_value in var.extra_envs :
    {
      name  = env_key,
      value = env_value
    }
    ]
  )
  naming_prefix = var.naming_prefix == "" ? "" : "${var.naming_prefix}-"
}

data "google_project" "project" {
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"

  disable_on_destroy = false
}

resource "google_service_account" "sa" {
  depends_on = [google_project_service.iam]

  account_id   = "${local.naming_prefix}cloud-scanning"
  display_name = "Service account for cloud-scanning"
}

resource "google_project_service" "pubsub" {
  service = "pubsub.googleapis.com"

  disable_on_destroy = false
}

resource "google_pubsub_topic" "topic" {
  depends_on = [google_project_service.pubsub]
  name       = "${local.naming_prefix}cloud-scanning-topic"
}

resource "google_project_service" "logging" {
  service = "logging.googleapis.com"

  disable_on_destroy = false
}

resource "google_logging_project_sink" "project_sink" {
  depends_on             = [google_project_service.logging, google_pubsub_topic.topic]
  name                   = "${local.naming_prefix}cloud-scanning-project-sink"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  unique_writer_identity = true
  filter                 = <<EOT
  protoPayload.methodName = "google.cloud.run.v1.Services.CreateService" OR protoPayload.methodName = "google.cloud.run.v1.Services.ReplaceService"
EOT
}

resource "google_pubsub_topic_iam_member" "writer" {
  project = google_pubsub_topic.topic.project
  topic   = google_pubsub_topic.topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.project_sink.writer_identity
}

resource "google_project_iam_member" "event_receiver" {
  role   = "roles/eventarc.eventReceiver"
  member = "serviceAccount:${google_service_account.sa.email}"
}

# Required to execute cloud build runs with this same service account
resource "google_project_iam_member" "service_account_user_itself" {
  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "builder" {
  role   = "roles/cloudbuild.builds.builder"
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_cloud_run_service_iam_member" "run_invoker" {
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.sa.email}"
  service  = google_cloud_run_service.cloud_scanning.name
  project  = google_cloud_run_service.cloud_scanning.project
  location = google_cloud_run_service.cloud_scanning.location
}

resource "google_project_iam_member" "token_creator" {
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  role   = "roles/iam.serviceAccountTokenCreator"
}

resource "google_project_service" "secret_manager" {
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

resource "google_secret_manager_secret" "secure_api_secret" {
  depends_on = [google_project_service.secret_manager]

  secret_id = "${local.naming_prefix}sysdig-secure-api-secret"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secure_api_secret" {
  secret = google_secret_manager_secret.secure_api_secret.id

  secret_data = var.sysdig_secure_api_token
}

resource "google_project_service" "eventarc" {
  service = "eventarc.googleapis.com"

  disable_on_destroy = false
}

resource "google_eventarc_trigger" "cloud_run" {
  depends_on      = [google_project_service.eventarc]
  name            = "${local.naming_prefix}cloud-scanning-trigger-cloudrun"
  location        = var.location
  service_account = google_service_account.sa.email
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.cloud_scanning.name
      region  = var.location
      path    = "/cloud_run_scanning"
    }
  }
  transport {
    pubsub {
      topic = google_pubsub_topic.topic.id
    }
  }
}

resource "google_pubsub_topic" "gcr" {
  depends_on = [google_project_service.pubsub]
  count      = var.create_gcr_topic ? 1 : 0
  name       = "gcr"
}

data "google_pubsub_topic" "gcr" {
  name = "gcr" # MUST exist in the infra of the customer, that's the only topic GCR will publish events to.
}

locals {
  gcr_topic_id = var.create_gcr_topic ? google_pubsub_topic.gcr[0].id : data.google_pubsub_topic.gcr.id
}

resource "google_eventarc_trigger" "gcr" {
  depends_on      = [google_project_service.eventarc]
  count           = length(local.gcr_topic_id[*]) > 0 ? 1 : 0 # We won't try to deploy this trigger if the GCR topic doesn't exist
  name            = "${local.naming_prefix}cloud-scanning-trigger-gcr"
  location        = var.location
  service_account = google_service_account.sa.email
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

resource "google_project_service" "cloud_run" {
  service = "run.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "cloud_build" {
  service = "cloudbuild.googleapis.com"

  disable_on_destroy = false
}

resource "google_cloud_run_service" "cloud_scanning" {
  depends_on = [google_project_service.cloud_run, google_project_service.cloud_build]

  location = var.location
  name     = "${local.naming_prefix}cloud-scanning"

  lifecycle {
    # We ignore changes in some annotations Cloud Run adds to the resource so we can
    # avoid unwanted recreations.
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
      template[0].metadata[0].annotations,
    ]
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal"
    }
  }

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = tostring(var.max_instances)
      }
    }

    spec {
      containers {
        image = var.image_name

        ports {
          container_port = 5000
        }

        env {
          #TODO: Put secrets in secretsmanager?
          name  = "SECURE_API_TOKEN"
          value = var.sysdig_secure_api_token
        }

        dynamic "env" {
          for_each = toset(local.task_env_vars)

          content {
            name  = env.value.name
            value = env.value.value
          }
        }
      }
      service_account_name = google_service_account.sa.email
    }
  }
}
