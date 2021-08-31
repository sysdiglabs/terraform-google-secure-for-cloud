output "bucket_config_md5hash" {
  value       = google_storage_bucket_object.config.md5hash
  description = "Cloud connector bucket config"
}

output "bucket_url" {
  value       = google_storage_bucket.bucket.url
  description = "Cloud connector bucket url"
}

output "bucket_config_name" {
  value       = google_storage_bucket_object.config.name
  description = "Cloud connector bucket config name"
}
