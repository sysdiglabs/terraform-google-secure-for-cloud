# This lines are here because of pre-commit hook
locals {
  default_config = <<EOF
logging: ${var.logging_level}
rules: []
ingestors:
  - gcp-auditlog-pubsub-http:
      url: /audit
      project: ${data.google_project.project.project_id}
notifiers: []
EOF
  config_content = var.config_content == null && var.config_source == null ? local.default_config : var.config_content
}

data "google_project" "project" {
  project_id = var.project_id
}
