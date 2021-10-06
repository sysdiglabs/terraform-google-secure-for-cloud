variable "project_id" {
  type        = string
  description = "ID of project to run the benchmark on"
}

variable "regions" {
  type        = list(string)
  description = "List of regions in which to run the benchmark. If empty, the task will contain all regions by default."
  default     = []
}

# --------------------------
# optionals, with defaults
# --------------------------
variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.naming_prefix))
    error_message = "ERROR: Invalid naming_prefix. must contain only lowercase letters (a-z) and numbers (0-9)."
  }
}
