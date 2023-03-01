variable "project_id" {
  type        = string
  description = "ID of project to run the benchmark on"
  default     = ""
}

variable "role_name" {
  type        = string
  description = "The name of the Service Account that will be created."
  default     = "sysdigcloudbench"
}

variable "reuse_workload_identity_pool" {
  type        = bool
  description = "Reuse existing workload identity pool, from previous deployment, with name 'sysdigcloud'. <br/> Will help overcome <a href='https://github.com/sysdiglabs/terraform-google-secure-for-cloud#q-getting-error-creating-workloadidentitypool-googleapi-error-409-requested-entity-already-exists'>redeploying error due to GCP softdelete</a><br/>"
  default     = false
}
