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
      value = var.cloud_connector_sa_email
    },
    {
      name  = "SECURE_API_TOKEN_SECRET"
      value = var.secure_api_token_secret_id
    }
    ], [for env_key, env_value in var.extra_envs :
    {
      name  = env_key,
      value = env_value
    }
    ]
  )
}

#FIXME: just use one data
data "google_project" "project" {
}

resource "google_cloud_run_service" "cloud_scanning" {
  location = var.location
  name     = "${var.naming_prefix}-cloud-scanning"

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
      service_account_name = var.cloud_connector_sa_email
    }
  }
}

resource "google_eventarc_trigger" "trigger" {
  name            = "${var.naming_prefix}-cloud-scanning-trigger"
  location        = var.location
  service_account = var.cloud_connector_sa_email
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
      topic = var.scanning_pubsub_topic_id
    }
  }
}

resource "google_cloud_run_service_iam_member" "run_invoker" {
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.cloud_connector_sa_email}"
  service  = google_cloud_run_service.cloud_scanning.name
  project  = google_cloud_run_service.cloud_scanning.project
  location = google_cloud_run_service.cloud_scanning.location
}
