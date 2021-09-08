# Single Project Example


This example deploys Cloud Connector and Cloud Scanning into a GCP account.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector) | ../../modules/services/cloud-connector |  |
| <a name="module_cloud_scanning"></a> [cloud\_scanning](#module\_cloud\_scanning) | ../../modules/services/cloud-scanning |  |
| <a name="module_connector_project_sink"></a> [connector\_project\_sink](#module\_connector\_project\_sink) | ../../modules/infrastructure/project_sink |  |
| <a name="module_scanning_project_sink"></a> [scanning\_project\_sink](#module\_scanning\_project\_sink) | ../../modules/infrastructure/project_sink |  |
| <a name="module_secure_secrets"></a> [secure\_secrets](#module\_secure\_secrets) | ../../modules/infrastructure/secrets |  |

## Resources

| Name | Type |
|------|------|
| [google_service_account.connector_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.scanning_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_gcr_topic"></a> [create\_gcr\_topic](#input\_create\_gcr\_topic) | Deploys a PubSub topic called `gcr` as part of this stack, which is needed for GCR scanning. Set to `true` if it doesn't exist yet. If this is not deployed, and no existing `gcr` topic is found, the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic). | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Zone where the stack will be deployed | `string` | `"us-central1"` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Naming prefix for all the resources created | `string` | `"sfc"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Google cloud project name | `string` | n/a | yes |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig's Secure API Token | `string` | n/a | yes |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://github.com/sysdiglabs/terraform-google-cloudvision).

## License

Apache 2 Licensed. See LICENSE for full details.
