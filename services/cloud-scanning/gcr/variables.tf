# Mandatory vars
variable "cloud_scanning_sa_email" {
  type        = string
  description = "Cloud-scanning SA email"
}

variable "create_gcr_topic" {
  type        = bool
  description = "Deploys a PubSub topic called `gcr` as part of this stack, which is needed for GCR scanning. Set to `true` only if it doesn't exist yet. If this is not deployed, and no existing `gcr` topic is found, the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic)."
}

variable "scanning_cloud_run_service_name" {
  type        = string
  description = "Cloud scanning cloud run service name"
}

# Default vars

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"
}

variable "location" {
  type        = string
  default     = "us-central1"
  description = "Zone where the cloud connector will be deployed"
}
