# Mandatory vars
variable "cloud_scanning_sa_email" {
  type        = string
  description = "Cloud-scanning SA email"
}

variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
  sensitive   = true
}

# Default vars

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"
}
