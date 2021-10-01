# Mandatory vars
variable "filter" {
  type        = string
  description = "Filter for project sink"
}

# --------------------------
# optionals, with defaults
# --------------------------
variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"

  validation {
    condition     = can(regex("^[a-z0-9_]+$", var.naming_prefix))
    error_message = "ERROR: Invalid naming_prefix. must contain only lowercase letters (a-z) and numbers (0-9)."
  }
}
