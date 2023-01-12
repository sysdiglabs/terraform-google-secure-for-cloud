variable "role_name" {
  type        = string
  description = "The name of the Service Account that will be created."
  default     = "sysdigcloudbench"
}

variable "organization_id" {
  type        = string
  description = "Numeric ID of the organization to be exported to the sink"
  default     = ""
}

variable "project_ids" {
  type        = list(string)
  description = "List of all gcp projects in org"
  default     = []
}

variable "organization_domain" {
  type        = string
  description = "Organization domain. e.g. sysdig.com"
  default     = ""
}

variable "project_id_number_map" {
  type        = map(string)
  description = "GCP project id to project number map"
  default     = {}
}

# For single project
variable "project_id" {
  type        = string
  description = "ID of project to run the benchmark on"
  default     = ""
}
