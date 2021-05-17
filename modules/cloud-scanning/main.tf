locals {
  task_env_vars = concat([
    {
      name  = "SECURE_URL"
      value = var.sysdig_secure_endpoint
    },
    {
      name  = "SECURE_API_TOKEN_SECRET"
      value = google_secret_manager_secret.secure_token.secret_id
    },
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "GCP_PROJECT"
      value = data.google_project.project.name
    },
    {
      name  = "GCR_DEPLOYED"
      value = tostring(var.deploy_gcr)
    },
    {
      name  = "CLOUDRUN_DEPLOYED"
      value = tostring(var.deploy_cloudrun)
    },
    {
      name  = "AUDITLOG_INTERVAL"
      value = "1m"
    },
    {
      name  = "CLOUDBUILD_SERVICE_ACCOUNT"
      value = google_service_account.cloudbuild.email
    },
    {
      name  = "CLOUDBUILD_BUCKET"
      value = google_storage_bucket.logs.name
    },
    {
      name  = "TELEMETRY_DEPLOYMENT_METHOD"
      value = "cft"
    }]
    , var.deploy_gcr ? [
      {
        name  = "GCR_PUBSUB_SUBSCRIPTION"
        value = google_pubsub_subscription.gcr_sub.name
      }
    ] : []
    , [for env_key, env_value in var.extra_envs :
      {
        name  = env_key,
        value = env_value
      }
    ]
  )
}

data "google_project" "project" {}

resource "google_service_account" "sa" {
  account_id   = "${lower(var.naming_prefix)}-cloudscanning"
  display_name = "Service account for cloudscanning"
}

#TODO: Specific role for reading from specific logs only?
resource "google_project_iam_member" "logging" {
  member = "serviceAccount:${google_service_account.sa.email}"
  role   = "roles/logging.viewer"
}

resource "google_project_iam_member" "cloudbuild" {
  member = "serviceAccount:${google_service_account.sa.email}"
  role   = "roles/cloudbuild.builds.editor"
}

resource "google_pubsub_subscription_iam_member" "editor" {
  subscription = google_pubsub_subscription.gcr_sub.name
  role         = "roles/editor"
  member       = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_service_account_iam_member" "builder" {
  service_account_id = google_service_account.cloudbuild.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_pubsub_subscription" "gcr_sub" {
  name = "${lower(var.naming_prefix)}-cloudscanning"

  #TODO: Must exist, otherwise error or create?
  topic = "gcr"

  expiration_policy {
    ttl = ""
  }

  enable_message_ordering = false
}

resource "google_secret_manager_secret" "secure_token" {
  secret_id = "${lower(var.naming_prefix)}-secure-api-token"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  secret      = google_secret_manager_secret.secure_token.id
  secret_data = var.sysdig_secure_api_token
}

resource "google_service_account" "cloudbuild" {
  account_id   = "${lower(var.naming_prefix)}-cloudbuild"
  display_name = "Service account for executing the scanning Cloud Build"
}

resource "google_secret_manager_secret_iam_member" "member" {
  project   = google_secret_manager_secret.secure_token.project
  secret_id = google_secret_manager_secret.secure_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_storage_bucket" "logs" {
  project       = data.google_project.project.name
  name          = "${lower(var.naming_prefix)}-scanning-logs"
  force_destroy = true
}

resource "google_storage_bucket_iam_member" "bucket_object_logger" {
  bucket = google_storage_bucket.logs.id
  member = "serviceAccount:${google_service_account.cloudbuild.email}"
  role   = "roles/storage.objectAdmin"
}

resource "google_storage_bucket_iam_member" "bucket_logger" {
  bucket = google_storage_bucket.logs.id
  member = "serviceAccount:${google_service_account.cloudbuild.email}"
  role   = "roles/storage.admin"
}

resource "google_cloud_run_service" "cloud_scanning" {
  depends_on = [google_project_iam_member.logging]
  location   = var.location
  name       = "${substr(lower(var.naming_prefix), 0, 49)}-cloudscanning"

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
      "run.googleapis.com/launch-stage" = "BETA"
    }
  }

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1"
        "autoscaling.knative.dev/maxScale" = "1"
      }
    }
    spec {
      container_concurrency = 1
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
