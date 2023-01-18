# Mandatory vars
variable "cloud_connector_sa_email" {
  type        = string
  description = "Cloud Connector service account email"
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

variable "connector_pubsub_topic_id" {
  type        = string
  description = "Cloud Connector PubSub single account topic id"
}

variable "project_id" {
  type        = string
  description = "organizational member project ID where the secure-for-cloud workload is going to be deployed"
}

variable "secure_api_token_secret_id" {
  type        = string
  description = "Sysdig Secure API token secret id"
}

# --------------------------
# optionals, with defaults
# --------------------------

variable "deploy_scanning" {
  type        = bool
  description = "true/false whether scanning module is to be deployed"
  default     = false
}

variable "verify_ssl" {
  type        = bool
  description = "Verify the SSL certificate of the Secure endpoint"
  default     = true
}

variable "image_name" {
  type        = string
  default     = "us-docker.pkg.dev/sysdig-public-registry/secure-for-cloud/cloud-connector:0.16.24"
  description = "Sysdig Owned Cloud Connector public image. GCP only allows the deployment of images that are registered in gcr.io"
}

variable "extra_envs" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Connector instance"
}

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc-cloudconnector"
}

variable "max_instances" {
  type        = number
  description = "Max number of instances for the Cloud Connector"
  default     = 1
}

variable "cpu" {
  type        = string
  default     = "1"
  description = "Amount of CPU to reserve for cloud-connector cloud run service"
}

variable "memory" {
  type        = string
  default     = "500Mi"
  description = "Amount of memory to reserve for cloud-connector cloud run service"
}

variable "is_organizational" {
  type        = bool
  default     = false
  description = "whether secure-for-cloud should be deployed in an organizational setup"
}
