locals {
  task_env_vars = concat([
    # This allows the revision to be created again if the configuration changes.
    # Annotations can't be used or they can't be ignored in the lifecycle, thus triggering
    # recreations even if the config hasn't changed.
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
    }]
    , [for env_key, env_value in var.extra_envs :
      {
        name  = env_key,
        value = env_value
      }
    ]
  )


}



resource "google_service_account" "sa" {
  account_id   = "${lower(var.naming_prefix)}-cloudconnector"
  display_name = "Service account for cloud-connector"
}

#TODO: Specific role for reading from required logs only?
resource "google_project_iam_member" "logging" {
  member = "serviceAccount:${google_service_account.sa.email}"
  role   = "roles/logging.viewer"
}

#TODO: Specific role for reading from the config bucket only?
resource "google_project_iam_member" "storage" {
  member = "serviceAccount:${google_service_account.sa.email}"
  role   = "roles/storage.objectViewer"
}

resource "google_storage_bucket" "bucket" {
  name          = var.bucket_config_name
  force_destroy = true
  versioning {
    # TODO Can we disable the versioning in this bucket, since the content is managed by Terraform?
    enabled = true
  }
}

resource "google_storage_bucket_object" "config" {
  bucket  = google_storage_bucket.bucket.id
  name    = "config.yaml"
  content = var.config_content
  source  = var.config_source
}

resource "google_cloud_run_service" "cloud_connector" {
  depends_on = [google_project_iam_member.logging, google_project_iam_member.storage]
  location   = var.location
  name       = "${substr(lower(var.naming_prefix), 0, 48)}-cloudconnector"

  lifecycle {
    # We ignore changes in some annotations Cloud Run adds to the resource so we can
    # avoid unwanted recreations.
    ignore_changes = [
      metadata.0.annotations,
      metadata.0.labels,
      template.0.metadata.0.annotations,
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
