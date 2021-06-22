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
    }], [for env_key, env_value in var.extra_envs :
    {
      name  = env_key,
      value = env_value
    }
    ]
  )
  default_config = <<EOF
rules: []
ingestors:
  - gcp-auditlog-pubsub-http:
      url: /audit
notifiers: []
EOF
  config_content = var.config_content == null && var.config_source == null ? local.default_config : var.config_content
  naming_prefix  = var.naming_prefix == "" ? "" : "${var.naming_prefix}-"
}

data "google_project" "project" {
}

resource "google_service_account" "sa" {
  account_id   = "${local.naming_prefix}cloud-connector"
  display_name = "Service account for cloud-connector"
}

#TODO: Specific role for reading from required logs only?
resource "google_project_iam_member" "logging" {
  member = "serviceAccount:${google_service_account.sa.email}"
  role   = "roles/logging.viewer"
}

resource "google_storage_bucket_iam_member" "read_access" {
  bucket = google_storage_bucket.bucket.id
  member = "serviceAccount:${google_service_account.sa.email}"
  role   = "roles/storage.legacyBucketReader"
}

resource "google_storage_bucket_iam_member" "list_objects" {
  bucket = google_storage_bucket.bucket.id
  member = "serviceAccount:${google_service_account.sa.email}"
  role   = "roles/storage.objectViewer"
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

resource "google_storage_bucket" "bucket" {
  name          = "${local.naming_prefix}${var.bucket_config_name}-${random_string.random.result}"
  force_destroy = true
  versioning {
    # TODO Can we disable the versioning in this bucket, since the content is managed by Terraform?
    enabled = true
  }
}

resource "google_storage_bucket_object" "config" {
  bucket  = google_storage_bucket.bucket.id
  name    = "config.yaml"
  content = local.config_content
  source  = var.config_source
}

resource "google_pubsub_topic" "topic" {
  name = "${local.naming_prefix}cloud-connector-topic"
}

resource "google_logging_project_sink" "project_sink" {
  depends_on             = [google_pubsub_topic.topic]
  name                   = "${local.naming_prefix}cloud-connector-project-sink"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  unique_writer_identity = true
  filter                 = <<EOT
  logName=~"^projects/${data.google_project.project.project_id}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
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

resource "google_cloud_run_service_iam_member" "run_invoker" {
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.sa.email}"
  service  = google_cloud_run_service.cloud_connector.name
  project  = google_cloud_run_service.cloud_connector.project
  location = google_cloud_run_service.cloud_connector.location
}

resource "google_project_iam_member" "token_creator" {
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  role   = "roles/iam.serviceAccountTokenCreator"
}

resource "google_eventarc_trigger" "trigger" {
  name            = "${local.naming_prefix}cloud-connector-trigger"
  location        = var.location
  service_account = google_service_account.sa.email
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
      topic = google_pubsub_topic.topic.id
    }
  }
}

resource "google_cloud_run_service" "cloud_connector" {
  depends_on = [google_project_iam_member.logging, google_storage_bucket_iam_member.read_access, google_storage_bucket_iam_member.list_objects]
  location   = var.location
  name       = "${local.naming_prefix}cloud-connector"

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
