terraform {
  required_version = ">= 0.14.0"

  required_providers {
    google = {
      source                = "hashicorp/google"
      version               = "~> 3.67.0"
      configuration_aliases = [google.multiproject]
    }
    google-beta = {
      source                = "hashicorp/google-beta"
      version               = "~> 3.67.0"
      configuration_aliases = [google-beta.multiproject]
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">= 0.5.21"
    }
  }
}
