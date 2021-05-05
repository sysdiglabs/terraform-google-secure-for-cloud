variable "name" {
  type        = string
  description = "Deployment Name"
}
variable "project_name" {
  type        = string
  description = "Project name of the Google Cloud Platform"
}
variable "secure_api_token" {
  type        = string
  description = "Sysdig's Secure API Token"
}
variable "secure_api_url" {
  type        = string
  description = "Sysdig's Secure API URL"
}
variable "verify_ssl" {
  type        = bool
  description = "Verify Sysdig's Secure SSL"
}
variable "location" {
  type        = string
  description = "Zone where the stack will be deployed"
}