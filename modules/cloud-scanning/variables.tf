variable "extra_envs" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Scanning deployment"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "Whether to verify the SSL certificate of the endpoint or not"
}

variable "deploy_gcr" {
  type        = bool
  description = "Enable GCR integration"
}

variable "deploy_cloudrun" {
  type        = bool
  description = "Enable CloudRun integration"
}

variable "image_name" {
  type        = string
  default     = "us-central1-docker.pkg.dev/mateo-burillo-ns/cloud-connector/cloud-scanning:gcp"
  description = "Image of the cloud scanning to deploy"
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

variable "project_name" {
  type        = string
  description = "Project name of the Google Cloud Platform"
}

variable "location" {
  type        = string
  default     = "us-central1"
  description = "Zone where the cloud scanning will be deployed"
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
