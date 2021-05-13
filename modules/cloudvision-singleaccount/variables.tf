variable "naming_prefix" {
  type        = string
  default     = "SysdigCloud"
  description = "Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly"

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\-]+$", var.naming_prefix)) && length(var.naming_prefix) > 1 && length(var.naming_prefix) <= 64
    error_message = "Must enter a naming prefix up to 64 alphanumeric characters."
  }
}

variable "location" {
  type        = string
  description = "Zone where the stack will be deployed"
}

variable "cloudconnector_deploy" {
  type        = bool
  default     = true
  description = "Whether to deploy or not CloudConnector"
}

# variable "cloudbench_deploy" {
#  type        = bool
#  default     = true
#  description = "Whether to deploy or not CloudBench"
#}

variable "gcr_image_scanning_deploy" {
  type        = bool
  default     = true
  description = "Whether to deploy or not GCR image scanning"
}

variable "cloudrun_image_scanning_deploy" {
  type        = bool
  default     = true
  description = "Whether to deploy or not CloudRun image scanning"
}

variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}
