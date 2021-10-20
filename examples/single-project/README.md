# Single Project Example

This example deploys Secure For Cloud into a single GCP project.
All the resources will be run in a single project.

![single project diagram](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/single-project/diagram-single.png?raw=true)

## Prerequisites

You **must** have following **roles** in your GCP organization/project credentials
* _Owner_

Besides, the following GCP **APIs must be enabled** to deploy resources correctly for:

### Cloud Connector
* [Cloud Pub/Sub API](https://console.cloud.google.com/marketplace/product/google/pubsub.googleapis.com)
* [Cloud Run API](https://console.cloud.google.com/marketplace/product/google/run.googleapis.com)
* [Eventarc API](https://console.cloud.google.com/marketplace/product/google/eventarc.googleapis.com)

### Cloud Scanning
* [Cloud Pub/Sub API](https://console.cloud.google.com/marketplace/product/google/pubsub.googleapis.com)
* [Cloud Run API](https://console.cloud.google.com/marketplace/product/google/run.googleapis.com)
* [Eventarc API](https://console.cloud.google.com/marketplace/product/google/eventarc.googleapis.com)
* [Secret Manger API](https://console.cloud.google.com/marketplace/product/google/secretmanager.googleapis.com)
* [Cloud Build API](https://console.cloud.google.com/marketplace/product/google/cloudbuild.googleapis.com)
* [Identity and access management API](https://console.cloud.google.com/marketplace/product/google/iam.googleapis.com)

 ### Cloud Benchmarks
* [Identity and access management API](https://console.cloud.google.com/marketplace/product/google/iam.googleapis.com)
* [IAM Service Account Credentials API](https://console.cloud.google.com/marketplace/product/google/iamcredentials.googleapis.com)
* [Cloud Resource Manager API](https://console.cloud.google.com/marketplace/product/google/cloudresourcemanager.googleapis.com)
* [Security Token Service API](https://console.cloud.google.com/marketplace/product/google/sts.googleapis.com)


## Usage

For quick testing, use this snippet on your terraform files

```
module "secure-for-cloud_example_single-project" {
  source  = "sysdiglabs/secure-for-cloud/google//examples/single-project"

  sysdig_secure_api_token   = "00000000-1111-2222-3333-444444444444"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.67.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 3.67.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_bench"></a> [cloud\_bench](#module\_cloud\_bench) | ../../modules/services/cloud-bench |  |
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID where the secure-for-cloud workload is going to be deployed | `string` | n/a | yes |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig's Secure API Token | `string` | n/a | yes |
| <a name="input_benchmark_regions"></a> [benchmark\_regions](#input\_benchmark\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all regions by default. | `list(string)` | `[]` | no |
| <a name="input_benchmark_role_name"></a> [benchmark\_role\_name](#input\_benchmark\_role\_name) | The name of the Service Account that will be created. | `string` | `"sysdigcloudbench"` | no |
| <a name="input_create_gcr_topic"></a> [create\_gcr\_topic](#input\_create\_gcr\_topic) | Deploys a PubSub topic called `gcr` as part of this stack, which is needed for GCR scanning. Set to `true` if it doesn't exist yet. If this is not deployed, and no existing `gcr` topic is found, the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic). | `bool` | `true` | no |
| <a name="input_deploy_bench"></a> [deploy\_bench](#input\_deploy\_bench) | whether benchmark module is to be deployed | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Zone where the stack will be deployed | `string` | `"us-central1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://github.com/sysdiglabs/terraform-google-cloudvision).

## License

Apache 2 Licensed. See LICENSE for full details.
