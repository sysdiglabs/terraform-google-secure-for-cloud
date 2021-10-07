variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig secure api token"
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "Project ID where the secure-for-cloud workload is going to be deployed"
}
