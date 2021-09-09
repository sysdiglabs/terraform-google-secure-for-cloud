# Mandatory vars
variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
}

variable "org_project_name" {
  type        = string
  description = "Google cloud project name"
}

# Vars with defaults
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
