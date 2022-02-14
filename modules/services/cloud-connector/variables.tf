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

variable "verify_ssl" {
  type        = bool
  description = "Verify the SSL certificate of the Secure endpoint"
  default     = true
}

variable "image_name" {
  type        = string
  default     = "gcr.io/mateo-burillo-ns/cloud-connector:latest"
  description = "Cloud Connector image to deploy"
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

variable "bucket_config_name" {
  type        = string
  description = "Google Cloud Storage Bucket where the configuration will be saved"
  default     = "cloud-connector-config"
}

variable "config_content" {
  default     = null
  type        = string
  description = "Contents of the configuration file to be saved in the bucket"
}

variable "config_source" {
  default     = null
  type        = string
  description = "Path to a file that contains the contents of the configuration file to be saved in the bucket"
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
