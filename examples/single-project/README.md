# Sysdig Secure for Cloud in GCP<br/>[ Example :: Single-Project ]

This example deploys Secure For Cloud into a single GCP project.<br/>
All the resources will be run in a single project.

![single project diagram](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/single-project/diagram-single.png?raw=true)

## Prerequisites

1. Configure [Terraform **GCP** Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
1. Following **roles** are required in your GCP organization/project credentials
   * _Owner_
1. Besides, the following GCP **APIs must be enabled** to deploy resources correctly for:

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

```terraform
provider "google" {
   project = "<PROJECT_ID>"
   region  = "<REGION_ID>; ex. us-central-1"
}

provider "google-beta" {
   project = "<PROJECT_ID>"
   region  = "<REGION_ID>; ex. us-central-1"
}

module "secure-for-cloud_example_single-project" {
  source = "sysdiglabs/secure-for-cloud/google//examples/single-project"
   sysdig_secure_url         = "<SYSDIG_SECURE_URL>"
   sysdig_secure_endpoint    = "<SYSDIG_SECURE_API_TOKEN>"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.67.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 3.67.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 3.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_bench"></a> [cloud\_bench](#module\_cloud\_bench) | ../../modules/services/cloud-bench | n/a |
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector) | ../../modules/services/cloud-connector | n/a |
| <a name="module_connector_project_sink"></a> [connector\_project\_sink](#module\_connector\_project\_sink) | ../../modules/infrastructure/project_sink | n/a |
| <a name="module_pubsub_http_subscription"></a> [pubsub\_http\_subscription](#module\_pubsub\_http\_subscription) | ../../modules/infrastructure/pubsub_push_http_subscription | n/a |
| <a name="module_secure_secrets"></a> [secure\_secrets](#module\_secure\_secrets) | ../../modules/infrastructure/secrets | n/a |

## Resources

| Name | Type |
|------|------|
| [google_service_account.connector_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig's Secure API Token | `string` | n/a | yes |
| <a name="input_benchmark_regions"></a> [benchmark\_regions](#input\_benchmark\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all regions by default. | `list(string)` | `[]` | no |
| <a name="input_benchmark_role_name"></a> [benchmark\_role\_name](#input\_benchmark\_role\_name) | The name of the Service Account that will be created. | `string` | `"sysdigcloudbench"` | no |
| <a name="input_deploy_benchmark"></a> [deploy\_benchmark](#input\_deploy\_benchmark) | whether benchmark module is to be deployed | `bool` | `true` | no |
| <a name="input_deploy_scanning"></a> [deploy\_scanning](#input\_deploy\_scanning) | true/false whether scanning module is to be deployed | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://github.com/sysdiglabs/terraform-google-secure-for-cloud).

## License

Apache 2 Licensed. See LICENSE for full details.
