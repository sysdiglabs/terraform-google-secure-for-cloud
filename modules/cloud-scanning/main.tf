locals {
  single_account = length(var.accounts_and_regions) == 0
  //  queue_url                   = local.single_account ? "https://sqs.${data.aws_region.current.name}.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.naming_prefix}-CloudScanning" : ""
  //  accounts_and_regions_string = join(",", [for a in var.accounts_and_regions : "${a.account_id}:${a.region}"])
  account_role   = local.single_account ? "" : "${var.naming_prefix}-CloudScanningRole"
  queue_name     = local.single_account ? "" : "${var.naming_prefix}-CloudScanning"
  task_env_vars  = concat([
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "SQS_QUEUE_INTERVAL"
      value = "30s"
    },
    //    {
    //      name  = "CODEBUILD_PROJECT"
    //      value = module.scanning_codebuild.project_id
    //    },
    //    {
    //      name  = "ECR_DEPLOYED"
    //      value = tostring(var.deploy_ecr)
    //    },
    //    {
    //      name  = "ECS_DEPLOYED"
    //      value = tostring(var.deploy_ecs)
    //    },
    {
      name  = "TELEMETRY_DEPLOYMENT_METHOD"
      value = "cft"
    },
    //    {
    //      name  = "SQS_QUEUE_URL"
    //      value = local.queue_url
    //    },
    {
      name  = "SQS_QUEUE_NAME"
      value = local.queue_name
    },
    //    {
    //      name  = "ACCOUNTS_AND_REGIONS"
    //      value = local.accounts_and_regions_string
    //    },
    {
      name  = "ACCOUNT_ROLE"
      value = local.account_role
    },
  ], flatten([for env_key, env_value in var.extra_env_vars : [{
    name  = env_key,
    value = env_value
  }]])
  )
}


resource "google_service_account" "sa" {
  account_id   = "${var.naming_prefix}-cloud-scanning-sa"
  display_name = "Service account for cloud-scanning"
}

resource "google_cloud_run_service" "cloud_connector" {
  //  depends_on = [google_project_iam_binding.logging, google_project_iam_binding.storage]
  location = var.location
  name     = "${var.naming_prefix}-cloud-scanning"

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
        image = var.image

        ports {
          container_port = 5000
        }

        env {
          name      = "SECURE_URL"
          valueFrom = var.secure_api_url
        }
        env {
          name      = "SECURE_API_TOKEN"
          valueFrom = var.secure_api_token
        }

        dynamic "env" {
          for_each = toset(local.task_env_vars)
          content {
            name  = env.value.name
            value = env.value.vale
          }
        }
      }
      service_account_name  = google_service_account.sa.email
    }
  }
}
