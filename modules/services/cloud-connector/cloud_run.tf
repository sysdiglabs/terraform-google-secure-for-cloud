locals {
  task_env_vars = concat([
    # This allows the revision to be created again if the configuration changes.
    # Annotations can't be used or they can't be ignored in the lifecycle, thus triggering
    # recreations even if the trust_relationship hasn't changed.
    {
      name  = "CONFIG_MD5"
      value = google_storage_bucket_object.config.md5hash
    },
    {
      name  = "CONFIG_PATH"
      value = "${google_storage_bucket.bucket.url}/${google_storage_bucket_object.config.output_name}"
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
      value = "terraform_gcp"
    },
    {
      name  = "GCP_REGION"
      value = var.location
    }
    ], [for env_key, env_value in var.extra_envs :
    {
      name  = env_key,
      value = env_value
    }
    ]
  )
}
resource "google_cloud_run_service" "cloud_connector" {
  location = var.location
  name     = "${var.naming_prefix}-cloud-connector"

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
  name            = "${var.naming_prefix}-cloud-connector-trigger"
  location        = var.location
  service_account = var.cloud_connector_sa_email
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    cloud_run_service {
      service = google_cloud_run_service.cloud_connector.name
      region  = var.location
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
