# Mandatory vars
variable "cloud_connector_sa_email" {
  type        = string
  description = "Cloud Connector service account email"
}

variable "project_id" {
  type        = string
  description = "organizational member project ID where the secure-for-cloud workload is going to be deployed"
}