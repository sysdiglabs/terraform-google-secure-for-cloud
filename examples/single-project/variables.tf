# Mandatory vars
variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
}

# --------------------------
# optionals, with defaults
# --------------------------
variable "location" {
  type        = string
  default     = "us-central1"
  description = "Zone where the stack will be deployed"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.naming_prefix))
    error_message = "ERROR: Invalid naming_prefix. must contain only lowercase letters (a-z) and numbers (0-9)."
  }
}

variable "create_gcr_topic" {
  type        = bool
  description = "Deploys a PubSub topic called `gcr` as part of this stack, which is needed for GCR scanning. Set to `true` if it doesn't exist yet. If this is not deployed, and no existing `gcr` topic is found, the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic)."
  default     = true
}

variable "regions" {
  type        = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all regions by default."
  default     = []
}

variable "role_name" {
  type        = string
  description = "The name of the Service Account that will be created."
  default     = "sysdigcloudbench"
}
