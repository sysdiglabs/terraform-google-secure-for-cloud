# Mandatory vars
variable "cloud_connector_sa_email" {
  type        = string
  description = "Cloud-connect SA email"
}

# Vars with defaults

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"
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
