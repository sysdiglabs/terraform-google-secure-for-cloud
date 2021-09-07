# This lines are here because of pre-commit hook
locals {
  task_env_vars = concat([
    {
      name  = "SECURE_URL"
      value = var.sysdig_secure_endpoint
    },
    {
      name  = "VERIFY_SSL"
      value = tostring(var.verify_ssl)
    },
    {
      name  = "GCP_PROJECT"
      value = data.google_project.project.project_id
    },
    {
      name  = "GCP_SERVICE_ACCOUNT"
      value = var.cloud_scanning_sa_email
    },
    {
      name  = "SECURE_API_TOKEN_SECRET"
      value = var.secure_api_token_secret_id
    }
    ], [for env_key, env_value in var.extra_envs :
    {
      name  = env_key,
      value = env_value
    }
    ]
  )
}

data "google_project" "project" {
}
