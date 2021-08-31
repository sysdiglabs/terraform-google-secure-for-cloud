module "gcr" {
  source = "./gcr"

  cloud_scanning_sa_email         = var.cloud_connector_sa_email
  scanning_cloud_run_service_name = google_cloud_run_service.cloud_scanning.name
  create_gcr_topic                = var.create_gcr_topic

  depends_on = [
  google_cloud_run_service.cloud_scanning]
}
