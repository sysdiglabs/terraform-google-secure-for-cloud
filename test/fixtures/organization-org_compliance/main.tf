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


# This two "multiproject" providers are required for benchmark trust-identity activation on the organizational level
provider "google" {
  alias  = "multiproject"
  region = var.region
}

provider "google-beta" {
  alias  = "multiproject"
  region = var.region
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

module "sfc_example_organization_org-compliance" {
  providers = {
    google.multiproject      = google.multiproject
    google-beta.multiproject = google-beta.multiproject
  }
  source = "../../../examples/organization-org_compliance"

  organization_domain = var.organization_domain
  name                = "sfc${random_string.random.result}"
}
