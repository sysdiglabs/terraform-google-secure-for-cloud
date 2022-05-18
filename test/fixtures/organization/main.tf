terraform {
  required_version = ">= 0.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.67.0"
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

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

# This provider is project agnostic, and can be used to provision resources in any project,
# provided the project is specified on the resource. Primarily used for Benchmarks
provider "google" {
  alias  = "multiproject"
  region = var.region
}

# This provider is project agnostic, and can be used to provision resources in any project,
# provided the project is specified on the resource. Primarily used for Benchmarks
provider "google-beta" {
  alias  = "multiproject"
  region = var.region
}

provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
}

module "sfc_example_organization" {
  source = "../../../examples/organization"

  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_endpoint  = var.sysdig_secure_endpoint

  organization_domain    = var.organization_domain
  name                   = "sfc${random_string.random.result}"
  repository_project_ids = [var.project_id]
  deploy_scanning        = true
  deploy_bench           = false
}
