terraform {
  required_version = ">= 0.15.0, < 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.21.0, < 5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.21.0, < 5.0.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.21"
    }
  }
}
