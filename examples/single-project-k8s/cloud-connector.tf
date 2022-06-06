resource "helm_release" "cloud_connector" {
  name = "cloud-connector"

  repository = "https://charts.sysdig.com"
  chart      = "cloud-connector"

  create_namespace = true
  namespace        = var.name
  atomic           = true
  timeout          = 60

  set_sensitive {
    name  = "sysdig.secureAPIToken"
    value = data.sysdig_secure_connection.current.secure_api_token
  }

  set {
    name  = "sysdig.url"
    value = data.sysdig_secure_connection.current.secure_url
  }

  set {
    name  = "sysdig.verifySSL"
    value = local.verify_ssl
  }

  set {
    name  = "telemetryDeploymentMethod"
    value = "terraform_gcp_k8s_single"
  }

  set {
    name  = "image.pullPolicy"
    value = "Always"
  }

  set {
    name  = "image.repository"
    value = "ghcr.io/sysdiglabs/cloud-connector"
  }

  set {
    name  = "image.tag"
    value = "pr-714"
  }

  values = [
    yamlencode(local.connector_config)
  ]
}