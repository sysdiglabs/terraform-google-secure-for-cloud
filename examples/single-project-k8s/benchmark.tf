provider "sysdig" {
  sysdig_secure_url          = var.sysdig_secure_endpoint
  sysdig_secure_api_token    = var.sysdig_secure_api_token
  sysdig_secure_insecure_tls = !local.verify_ssl
}

module "cloud_bench" {
  count  = var.deploy_benchmark ? 1 : 0
  source = "../../modules/services/cloud-bench"

  is_organizational = false
  role_name         = "${var.name}${var.benchmark_role_name}"
  project_id        = data.google_client_config.current.project
  regions           = var.benchmark_regions
}
