resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

resource "google_storage_bucket" "bucket" {
  name          = "${var.name}-${var.bucket_config_name}-${random_string.random.result}"
  force_destroy = true
  versioning {
    # TODO Can we disable the versioning in this bucket, since the content is managed by Terraform?
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "read_access" {
  bucket = google_storage_bucket.bucket.id
  member = "serviceAccount:${var.cloud_connector_sa_email}"
  role   = "roles/storage.legacyBucketReader"
}

resource "google_storage_bucket_iam_member" "list_objects" {
  bucket = google_storage_bucket.bucket.id
  member = "serviceAccount:${var.cloud_connector_sa_email}"
  role   = "roles/storage.objectViewer"
}

resource "google_storage_bucket_object" "config" {
  bucket  = google_storage_bucket.bucket.id
  name    = "config.yaml"
  content = local.config_content
  source  = var.config_source
}
