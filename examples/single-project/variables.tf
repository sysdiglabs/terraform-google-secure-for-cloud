# Mandatory vars
variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
}

# --------------------------
# optionals, with defaults
# --------------------------

#
# benchmark
#
variable "deploy_benchmark" {
  type        = bool
  description = "whether benchmark module is to be deployed"
  default     = true
}

variable "benchmark_regions" {
  type        = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all regions by default."
  default     = []
}

variable "benchmark_role_name" {
  type        = string
  description = "The name of the Service Account that will be created."
  default     = "sysdigcloudbench"
}


#
# general
#
variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.name))
    error_message = "ERROR: Invalid name. must contain only lowercase letters (a-z) and numbers (0-9)."
  }
}
