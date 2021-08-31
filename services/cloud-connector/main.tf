module "bucket" {
  source = "./bucket"

  cloud_connector_sa_email = var.cloud_connector_sa_email

  bucket_config_name = var.bucket_config_name
  naming_prefix      = var.naming_prefix
  config_content     = var.config_content
  config_source      = var.config_source
}
