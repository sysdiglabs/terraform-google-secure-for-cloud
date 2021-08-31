output "secure_api_token_secret_id" {
  value       = google_secret_manager_secret.secure_api_secret.id
  description = "Sysdig's Secure API Token secret ID"
}
