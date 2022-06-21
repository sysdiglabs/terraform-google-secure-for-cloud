terraform {
  required_version = ">= 0.15.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.21.0"
    }
    random = {
      version = ">= 3.1.0"
    }
    sysdig = {
      source = "sysdiglabs/sysdig"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.location
}

provider "google-beta" {
  project = var.project_id
  region  = var.location
}

provider "sysdig" {
  sysdig_secure_url       = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

module "sfc_example_single_project" {
  source = "../../../examples/single-project"

  name             = "sfc${random_string.random.result}"
  deploy_scanning    = true
  use_inline_scanner = false
  deploy_benchmark   = false
}
