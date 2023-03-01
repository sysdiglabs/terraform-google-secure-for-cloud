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

variable "project_id" {
  type        = string
  description = "Google cloud project ID in which Workload Identity Federation resources will be provisioned."
}

variable "project_ids" {
  type        = list(string)
  description = "Google cloud project IDs to onboard. If empty, all projects within the organization will be onboarded."
  default     = []
}

variable "organization_domain" {
  type        = string
  description = "Organization domain. e.g. sysdig.com"
}
