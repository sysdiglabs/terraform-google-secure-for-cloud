# Mandatory vars
variable "filter" {
  type        = string
  description = "Filter for project sink"
}

variable "organization_id" {
  type        = string
  description = "Numeric ID of the organization to be exported to the sink"
}

# Vars with defaults
variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"
}
