variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "sysdig_secure_api_token" {
  type        = string
  description = "Sysdig secure api token"
  sensitive   = true
}

variable "organization_domain" {
  type        = string
  description = "GCP organization domiain (e.g. domain.com)"
}

variable "project_id" {
  type        = string
  description = "Organization member project ID where the secure-for-cloud workload is going to be deployed"
}


variable "location" {
  type        = string
  default     = "us-central1"
  description = "Zone where the stack will be deployed"
}

variable "region" {
  type        = string
  description = "Region in which the cloudtrail and EKS are deployed. Currently same region is required"
  default     = "europe-north1"
}

