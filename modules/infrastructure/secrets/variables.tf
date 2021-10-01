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
variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"

  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.naming_prefix))
    error_message = "ERROR: Invalid naming_prefix. must contain only lowercase letters (a-z) and numbers (0-9)."
  }
}
