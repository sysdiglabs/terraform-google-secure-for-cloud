
# --------------------------
# optionals, with defaults
# --------------------------

variable "deploy_scanning" {
  type        = bool
  description = "true/false whether scanning module is to be deployed"
  default     = false
}


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


variable "cloud_connector_image" {
  type        = string
  description = "The image to use for the Cloud Connector."
  default     = "us-docker.pkg.dev/sysdig-public-registry/secure-for-cloud/cloud-connector:latest"
}

variable "reuse_workload_identity_pool" {
  type        = bool
  description = "Reuse existing workload identity pool, with name 'sysdigcloud'. Can be used when redeploying after destroy, by undeleting the previous workload identity pool, which is kept for 30 days and results in an error in redeployment."
  default     = false
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
