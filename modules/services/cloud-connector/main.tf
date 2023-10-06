locals {
  suffix_org = var.is_organizational ? "org" : "single"
  task_env_vars = concat([
    # This allows the revision to be created again if the configuration changes.
    # Annotations can't be used or they can't be ignored in the lifecycle, thus triggering
    # recreations even if the config hasn't changed.
    {
      name  = "CONFIG"
      value = base64encode(local.config_content)
    },
    {
      name  = "SECURE_URL"
      value = var.sysdig_secure_endpoint
    },
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "TELEMETRY_DEPLOYMENT_METHOD"
      value = "terraform_gcp_cr_${local.suffix_org}"
    },
    {
      name  = "GCP_REGION"
      value = data.google_client_config.current.region
    }
    ], [
    for env_key, env_value in var.extra_envs :
    {
      name  = env_key,
      value = env_value
    }
    ]
  )
}


resource "google_cloud_run_service" "cloud_connector" {
  location = data.google_client_config.current.region
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

        resources {
          limits = {
            cpu    = var.cpu,
            memory = var.memory,
          }
        }

        ports {
          container_port = 5000
        }

        dynamic "env" {
          for_each = var.sysdig_secure_api_token == "" ? to_set([]) : to_set([1])

          content {
            name  = "SECURE_API_TOKEN"
            value = var.sysdig_secure_api_token
          }
        }

        dynamic "env" {
          for_each = var.sysdig_secure_api_token_secret_id == "" ? to_set([]) : to_set([1])

          content {
            name = "SECURE_API_TOKEN"
            value_from {
              secret_key_ref {
                name = var.sysdig_secure_api_token_secret_id
                key  = "latest"
              }
            }
          }
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
  name            = "${var.name}-trigger"
  location        = data.google_client_config.current.region
  service_account = var.cloud_connector_sa_email
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.cloud_connector.name
      region  = data.google_client_config.current.region
      path    = "/audit"
    }
  }
  transport {
    pubsub {
      topic = var.connector_pubsub_topic_id
    }
  }
}

resource "google_cloud_run_service_iam_member" "run_invoker" {
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.cloud_connector_sa_email}"
  service  = google_cloud_run_service.cloud_connector.name
  project  = google_cloud_run_service.cloud_connector.project
  location = google_cloud_run_service.cloud_connector.location
}

resource "google_project_iam_member" "run_viewer" {
  project = var.project_id
  member  = "serviceAccount:${var.cloud_connector_sa_email}"
  role    = "roles/run.viewer"
}
