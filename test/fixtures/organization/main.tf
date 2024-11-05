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


provider "sysdig" {
  sysdig_secure_url       = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token
}

provider "google" {
  project = var.project_id
  region  = var.location
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

module "sfc_example_organization" {
  source = "../../../examples/organization"

  organization_domain    = var.organization_domain
  name                   = "sfc${random_string.random.result}"
  repository_project_ids = [var.project_id]
  deploy_scanning        = true
}
