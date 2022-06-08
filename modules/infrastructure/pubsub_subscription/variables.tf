variable "push_to_cloudrun" {
  type        = bool
  description = "true/false whether GCR subscription should push events to Cloud run or not"
}

variable "deploy_scanning" {
  type        = bool
  description = "true/false whether scanning module is to be deployed"
  default     = false
}

variable "gcr_topic_name" {
  type        = string
  description = "Topic to create a subscription"
}

variable "pubsub_topic_name" {
  type        = string
  description = "PubSub topic name fot auditlog"
  default     = ""
}

variable "push_http_endpoint" {
  type        = string
  description = "HTTP endpoint to push the events to"
  default     = ""
}

variable "subscription_project_id" {
  type        = string
  description = "Project ID where the subscription must be created"
}

variable "service_account_email" {
  type        = string
  description = "Service account email to use"
}

variable "topic_project_id" {
  type        = string
  description = "Project ID where the topic exists / must be created"
}

variable "name" {
  type        = string
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}
