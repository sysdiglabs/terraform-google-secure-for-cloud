# Cloud Bench deploy in GCP Module

This repository contains a Module for how to deploy the Cloud Bench in the Google Cloud Platform as a Cloud Run
deployment that will detect events in your infrastructure.

## Usage

```hcl
module "cloud_bench_gcp" {
  source = "sysdiglabs/cloudvision/google/modules/cloud-bench"

  config_bucket    = "cloud-bench-config-bucket"
  secure_api_token = "00000000-1111-2222-3333-444444444444"
  secure_api_url   = "https://secure.sysdig.com"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
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
| [google_service_account.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket_object.config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_bucket"></a> [config\_bucket](#input\_config\_bucket) | Name of a bucket (must exist) where the configuration YAML files will be stored | `string` | n/a | yes |
| <a name="input_config_content"></a> [config\_content](#input\_config\_content) | Configuration contents for the file stored in the bucket | `string` | `null` | no |
| <a name="input_config_source"></a> [config\_source](#input\_config\_source) | Configuration source file for the file stored in the bucket | `string` | `null` | no |
| <a name="input_extra_env_vars"></a> [extra\_env\_vars](#input\_extra\_env\_vars) | Extra environment variables for the Cloud Scanning deployment | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | Image of the cloud bench to deploy | `string` | `"sysdiglabs/cloud-bench:latest"` | no |
| <a name="input_location"></a> [location](#input\_location) | Zone where the cloud bench will be deployed | `string` | `"us-central1"` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for resource names. Use the default unless you need to install multiple instances, and modify the deployment at the main account accordingly | `string` | `"SysdigCloud"` | no |
| <a name="input_secure_api_token"></a> [secure\_api\_token](#input\_secure\_api\_token) | Sysdig's Secure API Token | `string` | n/a | yes |
| <a name="input_secure_api_url"></a> [secure\_api\_url](#input\_secure\_api\_url) | Sysdig's Secure API URL | `string` | n/a | yes |
| <a name="input_verify_ssl"></a> [verify\_ssl](#input\_verify\_ssl) | Whether to verify the SSL certificate of the endpoint or not | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Sysdig](https://github.com/sysdiglabs/terraform-google-cloudvision).

## License

Apache 2 Licensed. See LICENSE for full details.
