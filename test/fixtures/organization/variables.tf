variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig secure api token"
  sensitive   = true
}

variable "project_id" {
  type        = string
  description = "GCP project id where the resources will be deployed"
}

variable "organization_domain" {
  type        = string
  description = "GCP organization domiain (e.g. domain.com)"
}
