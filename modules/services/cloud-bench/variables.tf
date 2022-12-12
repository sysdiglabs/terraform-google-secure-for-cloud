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

#For single project
variable "project_id" {
  type        = string
  description = "Google cloud project ID to run Benchmarks on. It will create a trust-relationship, to allow Sysdig usage."
  default     = ""
}

# For organizational
variable "project_ids" {
  type        = list(string)
  description = "Google cloud project IDs to run Benchmarks on. It will create a trust-relationship on each, to allow Sysdig usage. If empty, all organization projects will be defaulted."
  default     = []
}

variable "is_organizational" {
  type        = bool
  description = "Whether this task is being created at the org or project level"
  default     = false
}

variable "organization_domain" {
  type        = string
  description = "Organization domain. e.g. sysdig.com"
  default     = ""
}

variable "reuse_workload_identity_pool" {
  type        = bool
  description = "Reuse existing workload identity pool"
  default     = false
}