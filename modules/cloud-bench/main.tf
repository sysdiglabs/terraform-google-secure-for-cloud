locals {
  default_config = <<CONFIG
secureURL: "value overriden by SECURE_URL env var"
logLevel: "debug"
schedule: "24h"
benchmarkType: "aws"
outputDir: "/tmp/cloud-custodian"
policyFile: "/home/custodian/aws-benchmarks.yml"
CONFIG
  task_env_vars = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    ], flatten([for env_key, env_value in var.extra_env_vars : [{
      name  = env_key,
      value = env_value
    }]])
  )
}


resource "google_storage_bucket_object" "config" {
  bucket  = var.config_bucket
  name    = "cloud-bench.yaml"
  content = var.config_content == null && var.config_source == null ? local.default_config : var.config_content
  source  = var.config_source
}

resource "google_service_account" "sa" {
  account_id   = "${var.naming_prefix}-cloud-bench-sa"
  display_name = "Service account for cloud-bench"
}

resource "google_cloud_run_service" "cloud_connector" {
  # depends_on = [google_project_iam_binding.logging, google_project_iam_binding.storage]
  location = var.location
  name     = "${var.naming_prefix}-cloud-bench"

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
        image = var.image

        ports {
          container_port = 7000
        }

        env {
          name  = "SECURE_URL"
          value = var.secure_api_url
        }
        env {
          name  = "SECURE_API_TOKEN"
          value = var.secure_api_token
        }

        dynamic "env" {
          for_each = toset(local.task_env_vars)
          content {
            name  = env.value.name
            value = env.value.vale
          }
        }
      }
      service_account_name = google_service_account.sa.email
    }
  }
}
