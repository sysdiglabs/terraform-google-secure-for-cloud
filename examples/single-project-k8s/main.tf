locals {
  verify_ssl       = length(regexall("^https://.*?\\.sysdig.com/?", data.sysdig_secure_connection.current.secure_url)) != 0
  connector_filter = <<EOT
  logName=~"^projects/${data.google_client_config.current.project}/logs/cloudaudit.googleapis.com" AND -resource.type="k8s_cluster"
EOT
}
