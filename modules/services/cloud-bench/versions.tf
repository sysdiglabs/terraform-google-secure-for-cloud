terraform {
  required_version = ">= 0.14.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 3.67.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.67.0"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.21"
    }
  }
}
