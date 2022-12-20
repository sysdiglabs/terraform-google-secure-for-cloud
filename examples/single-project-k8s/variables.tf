
# --------------------------
# optionals, with defaults
# -------------------------

variable "deploy_scanning" {
  type        = bool
  description = "true/false whether scanning module is to be deployed"
  default     = false
}

# benchmark
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

variable "reuse_workload_identity_pool" {
  type        = bool
  description = "Reuse existing workload identity pool, with name 'sysdigcloud'. Can be used when redeploying after destroy, by undeleting the previous workload identity pool, which is kept for 30 days and results in an error in redeployment."
  default     = false
}


# general
variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.name))
    error_message = "ERROR: Invalid name. must contain only lowercase letters (a-z) and numbers (0-9)."
  }
}

variable "cloud_connector_image" {
  type        = string
  description = "Cloud-connector image to deploy"
  default     = "quay.io/sysdig/cloud-connector"
}
