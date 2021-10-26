resource "google_cloud_run_service" "cloud_scanning" {
  location = var.location
  name     = var.name

  lifecycle {
    # We ignore changes in some annotations Cloud Run adds to the resource so we can
    # avoid unwanted recreations.
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
      template[0].metadata[0].annotations,
      template[0].spec[0].containers[0].ports[0].name
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
      service_account_name = var.cloud_scanning_sa_email
    }
  }
}

resource "google_eventarc_trigger" "trigger" {
  name            = "${var.name}-trigger"
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
      path    = "/cloud_run_scanning"
    }
  }
  transport {
    pubsub {
      topic = var.scanning_pubsub_topic_id
    }
  }
}

resource "google_project_iam_member" "cloud_run_viewer" {
  member = "serviceAccount:${var.cloud_scanning_sa_email}"
  role   = "roles/run.viewer"
}

resource "google_cloud_run_service_iam_member" "run_invoker" {
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.cloud_scanning_sa_email}"
  service  = google_cloud_run_service.cloud_scanning.name
  project  = google_cloud_run_service.cloud_scanning.project
  location = google_cloud_run_service.cloud_scanning.location
}
