variable "config_bucket" {
  type        = string
  description = "Name of a bucket (must exist) where the configuration YAML files will be stored"
}

variable "config_content" {
  type        = string
  description = "Configuration contents for the file stored in the bucket"
  default     = null
}

variable "config_source" {
  type        = string
  description = "Configuration source file for the file stored in the bucket"
  default     = null
}

variable "location" {
  type        = string
  default     = "us-central1"
  description = "Zone where the cloud bench will be deployed"
}

variable "secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
}

variable "secure_api_url" {
  type        = string
  description = "Sysdig's Secure API URL"
}

variable "extra_env_vars" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Scanning deployment"
}

variable "image" {
  type        = string
  default     = "sysdiglabs/cloud-bench:latest"
  description = "Image of the cloud bench to deploy"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "Whether to verify the SSL certificate of the endpoint or not"
}

variable "naming_prefix" {
  type        = string
  default     = "SysdigCloud"
  description = "Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly"

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]+$", var.naming_prefix)) && length(var.naming_prefix) > 1 && length(var.naming_prefix) <= 64
    error_message = "Must enter a naming prefix up to 64 alphanumeric characters."
  }
}
