# Mandatory vars
variable "filter" {
  type        = string
  description = "Filter for project sink"
}

# Vars with defaults
variable "name" {
  type        = string
  description = "Naming prefix for all the resources created"
  default     = "sfc"
}
