terraform {
  required_version = ">= 0.15.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.21.0"
    }
    sysdig = {
      source  = "local/sysdiglabs/sysdig"
      version = "~> 1.0.0"
    }
    random = {
      version = ">= 3.1.0"
    }
  }
}