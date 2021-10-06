variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig secure api token"
  sensitive   = true
}

variable "organization_domain" {
  type        = string
  description = "GCP organization domiain (e.g. domain.com)"
}
