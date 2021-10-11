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
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
  default     = "sfc"
}
