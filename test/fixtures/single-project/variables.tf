variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig secure api token"
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "Project ID where the secure-for-cloud workload is going to be deployed"
}


variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "location" {
  type        = string
  default     = "us-central1"
  description = "Zone where the stack will be deployed"
}
