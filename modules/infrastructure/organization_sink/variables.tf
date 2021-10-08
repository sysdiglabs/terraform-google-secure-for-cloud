# Mandatory vars
variable "filter" {
  type        = string
  description = "Filter for project sink"
}

variable "organization_id" {
  type        = string
  description = "Numeric ID of the organization to be exported to the sink"
}

# --------------------------
# optionals, with defaults
# --------------------------
variable "name" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"
}
