
terraform {
  required_version = ">= 0.12.26"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.67.0"
    }
  }
}