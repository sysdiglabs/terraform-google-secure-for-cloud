# Mandatory vars
variable "filter" {
  type        = string
  description = "Filter for project sink"
}

variable "organization_id" {
  type        = string
  description = "Numeric ID of the organization to be exported to the sink"
}

variable "service" {
  type        = string
  description = "This string must contains 'scanning' or 'connector' depending on the service you want to deploy"

  validation {
    condition = contains([
      "connector",
    "scanning"], var.service)
    error_message = "Valid values for var: service are (connector, scanning)."
  }
}
# Vars with defaults
variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"
}
