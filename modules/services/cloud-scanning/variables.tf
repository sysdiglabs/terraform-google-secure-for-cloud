# mandatory vars
variable "cloud_scanning_sa_email" {
  type        = string
  description = "Cloud Connector service account email"
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

variable "create_gcr_topic" {
  type        = bool
  description = "true / false whether a `gcr`-named pubsub topic will be created. Needed for GCR scanning. If this topic does not exist nor is created,  the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic)."
  default     = true
}


variable "repository_project_ids" {
  type        = list(string)
  description = "Projects were a `gcr`-named topic will be to subscribe to its repository events. If empty, all organization projects will be defaulted."
  default     = []
}



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
