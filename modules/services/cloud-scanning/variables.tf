# mandatory vars
variable "cloud_scanning_sa_email" {
  type        = string
  description = "Cloud Connector service account email"
}

variable "create_gcr_topic" {
  type        = bool
  description = "Deploys a PubSub topic called `gcr` as part of this stack, which is needed for GCR scanning. Set to `true` only if it doesn't exist yet. If this is not deployed, and no existing `gcr` topic is found, the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic)."
}

variable "secure_api_token_secret_id" {
  type        = string
  description = "Sysdig Secure API token secret id"
}

variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
  sensitive   = true
}

variable "sysdig_secure_endpoint" {
  type        = string
  description = "Sysdig's Secure API URL"
}

variable "scanning_pubsub_topic_id" {
  type        = string
  description = "Cloud Scanning PubSub single account topic id"
}

variable "project_id" {
  type        = string
  description = "organizational member project ID where the secure-for-cloud workload is going to be deployed"
}


# --------------------------
# optionals, with defaults
# --------------------------

variable "verify_ssl" {
  type        = bool
  description = "Verify the SSL certificate of the Secure endpoint"
  default     = true
}

variable "location" {
  type        = string
  default     = "us-central1"
  description = "Zone where the cloud scanning will be deployed"
}

variable "image_name" {
  type        = string
  default     = "gcr.io/mateo-burillo-ns/cloud-scanning:latest"
  description = "Cloud scanning image to deploy"
}

variable "extra_envs" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Scanning instance"
}

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc-cloudscanning"
}

variable "max_instances" {
  type        = number
  description = "Max number of instances for the Cloud Scanning"
  default     = 1
}
