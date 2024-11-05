
# --------------------------
# optionals, with defaults
# --------------------------

variable "deploy_scanning" {
  type        = bool
  description = "true/false whether scanning module is to be deployed"
  default     = false
}

variable "cloud_connector_image" {
  type        = string
  description = "The image to use for the Cloud Connector."
  default     = "us-docker.pkg.dev/sysdig-public-registry/secure-for-cloud/cloud-connector:latest"
}

#
# general
#
variable "name" {
  type        = string
  description = "Suffix to be assigned to all created resources. Modify this value in case of conflict / 409 error to bypass Google soft delete issues"
  default     = "sfc"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.name))
    error_message = "ERROR: Invalid name. must contain only lowercase letters (a-z) and numbers (0-9)."
  }
}
