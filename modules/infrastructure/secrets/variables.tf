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

# --------------------------
# optionals, with defaults
# --------------------------
variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}
