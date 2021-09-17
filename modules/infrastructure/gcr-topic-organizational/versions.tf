terraform {
  required_version = ">= 0.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.67.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }
}
