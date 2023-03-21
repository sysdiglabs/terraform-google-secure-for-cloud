variable "role_name" {
  type        = string
  description = "The name of the Service Account/Role that will be created. Modify this value in case of conflict / 409 error to bypass Google soft delete"
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

# Linting ignored as published snippets still reference this param, and will fail if it is removed.
# tflint-ignore: terraform_unused_declarations
variable "organization_domain" {
  type        = string
  description = "Organization domain. e.g. sysdig.com"
  default     = ""
}

variable "reuse_workload_identity_pool" {
  type        = bool
  description = "Reuse existing workload identity pool, from previous deployment, with name 'sysdigcloud'. <br/> Will help overcome <a href='https://github.com/sysdiglabs/terraform-google-secure-for-cloud#q-getting-error-creating-workloadidentitypool-googleapi-error-409-requested-entity-already-exists'>redeploying error due to GCP softdelete</a><br/>"
  default     = false
}
