terraform {
  required_version = ">= 0.15.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.67.0"
    }
    random = {
      version = ">= 3.1.0"
    }
  }
}
