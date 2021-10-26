locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", var.sysdig_secure_endpoint)) != 0
  connector_filter = <<EOT
  logName=~"^projects/${var.project_id}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
EOT
}

provider "google" {
  project = var.project_id
  region  = var.location
}

# TODO review ways to pass content as input var
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
