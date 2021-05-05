variable "project_name" {
  type        = string
  description = "Project name of the Google Cloud Platform"
}

variable "secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
  sensitive   = true
}

variable "verify_ssl" {
  type        = bool
  description = "Verify the SSL certificate of the Secure endpoint"
  default     = true
}

variable "name" {
  type        = string
  default     = "cloud-connector"
  description = "Name for the Cloud Connector deployment"
}

variable "location" {
  type        = string
  default     = "us-central1"
  description = "Zone where the cloud connector will be deployed"
}

variable "image_name" {
  type        = string
  default     = "us-central1-docker.pkg.dev/mateo-burillo-ns/cloud-connector/cloud-connector:config"
  description = "Cloud Connector image to deploy"
}

variable "extra_envs" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Connector instance"
}

variable "bucket_config_name" {
  type        = string
  description = "Google Cloud Storage Bucket where the configuration will be saved"
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