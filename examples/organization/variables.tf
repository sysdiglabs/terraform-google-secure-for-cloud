# Mandatory vars
variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
}

variable "organization_domain" {
  type        = string
  description = "Organization domain. e.g. sysdig.com"
}

variable "project_id" {
  type        = string
  description = "Organization member project ID where the secure-for-cloud workload is going to be deployed"
}

variable "project_scan_ids" {
  type        = list(string)
  description = "Projects where a subscription must be created to pull events from their GCR topics. Warning, the GCR topic must already exist in each provided project."
  default     = []
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

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.name))
    error_message = "ERROR: Invalid name. must contain only lowercase letters (a-z) and numbers (0-9)."
  }
}

variable "max_instances" {
  type        = number
  description = "Max number of instances for the workloads"
  default     = 1
}

variable "create_gcr_topic" {
  type        = bool
  description = "Deploys a PubSub topic called `gcr` as part of this stack, which is needed for GCR scanning. Set to `true` only if it doesn't exist yet. If this is not deployed, and no existing `gcr` topic is found, the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic)."
  default     = true
}

variable "benchmark_regions" {
  type        = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all regions by default."
  default     = []
}

variable "benchmark_project_ids" {
  default     = []
  type        = list(string)
  description = "Google cloud project IDs to run Benchmarks on"
}

variable "role_name" {
  type        = string
  description = "The name of the Service Account that will be created."
  default     = "sysdigcloudbench"
}

variable "deploy_bench" {
  type        = bool
  description = "whether benchmark module is to be deployed"
  default     = true
}
