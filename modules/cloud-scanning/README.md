# Cloud Scanning deploy in GCP Module

This repository contains a Module for how to deploy the Cloud Scanning in the Google Cloud Platform as a Cloud Run
deployment that will detect events in your infrastructure.

## Usage

```hcl
module "cloud_scanning_gcp" {
  source = "sysdiglabs/cloudvision/google/modules/cloud-scanning"

  deploy_cloudrun         = true
  deploy_gcr              = true
  sysdig_secure_api_token = "00000000-1111-2222-3333-444444444444"
  sysdig_secure_endpoint  = "https://secure.sysdig.com"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service.cloud_connector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service) | resource |
| [google_project_iam_member.cloudbuild](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.gcr_sub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription_iam_member.editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_member) | resource |
| [google_service_account.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deploy_cloudrun"></a> [deploy\_cloudrun](#input\_deploy\_cloudrun) | Enable CloudRun integration | `bool` | n/a | yes |
| <a name="input_deploy_gcr"></a> [deploy\_gcr](#input\_deploy\_gcr) | Enable GCR integration | `bool` | n/a | yes |
| <a name="input_extra_envs"></a> [extra\_envs](#input\_extra\_envs) | Extra environment variables for the Cloud Scanning deployment | `map(string)` | `{}` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Image of the cloud scanning to deploy | `string` | `"us-central1-docker.pkg.dev/mateo-burillo-ns/cloud-connector/cloud-scanning:gcp"` | no |
| <a name="input_location"></a> [location](#input\_location) | Zone where the cloud scanning will be deployed | `string` | `"us-central1"` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly | `string` | `"SysdigCloud"` | no |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig's Secure API Token | `string` | n/a | yes |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig's Secure API URL | `string` | n/a | yes |
| <a name="input_verify_ssl"></a> [verify\_ssl](#input\_verify\_ssl) | Whether to verify the SSL certificate of the endpoint or not | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://github.com/sysdiglabs/terraform-google-cloudvision).

## License

Apache 2 Licensed. See LICENSE for full details.
