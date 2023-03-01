module "cloud_bench" {
  count  = var.deploy_benchmark ? 1 : 0
  source = "../../modules/services/cloud-bench"

  is_organizational            = false
  role_name                    = "${var.name}${var.benchmark_role_name}"
  project_id                   = data.google_client_config.current.project
  regions                      = var.benchmark_regions
  reuse_workload_identity_pool = var.reuse_workload_identity_pool
}
