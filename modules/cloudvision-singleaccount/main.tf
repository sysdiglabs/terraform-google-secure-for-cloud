module "cloud-connector" {
  source = "../cloud-connector"

  name               = "${var.name}-cloud-connector"
  location           = var.location
  bucket_config_name = var.name
  project_name       = var.project_name
  secure_api_token   = var.secure_api_token
  verify_ssl         = var.verify_ssl
  config_content     = <<EOF
rules:
  - secure:
      url: ${var.secure_api_url}
ingestors:
  - auditlog:
      project: ${var.project_name}
      interval: 10m
notifiers:
  - secure:
      url: ${var.secure_api_url}
  EOF
}