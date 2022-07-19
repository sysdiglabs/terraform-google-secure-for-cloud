# Sysdig Secure for Cloud in GCP<br/>[ Example :: Organization ]

This example deploys Secure for Cloud into a GCP organizational account.

### Notice
* Sysdig workload will be deployed in the `project_id` defined in the required input parameter.
* All Sysdig Secure for Cloud features but [Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/) are enabled by default. You can enable it through `deploy_scanning` input variable parameters.<br/>
* This example will create resources that **cost money**. Run `terraform destroy` when you don't need them anymore.
* For **free subscription** users, beware that this example may not deploy properly due to the [1 cloud-account limitation](https://docs.sysdig.com/en/docs/administration/administration-settings/subscription/#cloud-billing-free-tier). Open an Issue so we can help you here!

![single project diagram](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/organization/diagram-org.png?raw=true)

## Prerequisites

1. Configure [Terraform **GCP** Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
2. Following **roles** are required in your GCP organization/project credentials
   * _Owner_
   * _Organization Admin_
3. Besides, the following GCP **APIs must be enabled** to deploy resources correctly for:

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

For quick testing, use this snippet on your terraform files and provide following parameters
- `SYSDIG_SECURE_URL / SYSDIG_SECURE_API_TOKEN` Sysdig Authentication
- `ORG_DOMAIN` GCP organization identification
- `PROJECT_ID` GCP project where workload will be deployed
- `REGION_ID` for the workload to be deployed
 

```terraform
terraform {
   required_providers {
      sysdig = {
         source  = "sysdiglabs/sysdig"
      }
   }
}

provider "sysdig" {
   sysdig_secure_url         = "<SYSDIG_SECURE_URL>"
   sysdig_secure_api_token   = "<SYSDIG_SECURE_API_TOKEN>"
}

provider "google" {
   project = "<PROJECT_ID>"
   region  = "<REGION_ID>; ex. us-central1"
}

# This two "multiproject" providers are required for benchmark trust-identity activation on the organizational level
provider "google" {
   alias  = "multiproject"
   region = "<REGION_ID>; ex. us-central1"
}

provider "google-beta" {
   alias  = "multiproject"
   region = "<REGION_ID>; ex. us-central1"
}


module "secure-for-cloud_example_organization" {
  providers = {
    google.multiproject      = google.multiproject
    google-beta.multiproject = google-beta.multiproject
  }

  source = "sysdiglabs/secure-for-cloud/google//examples/organization"  
  organization_domain       = "<ORG_DOMAIN>"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.21.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.21.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.24.0 |
| <a name="provider_sysdig"></a> [sysdig](#provider\_sysdig) | 0.5.37 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_bench"></a> [cloud\_bench](#module\_cloud\_bench) | ../../modules/services/cloud-bench | n/a |
| <a name="module_cloud_build_permission"></a> [cloud\_build\_permission](#module\_cloud\_build\_permission) | ../../modules/infrastructure/cloud_build_permission | n/a |
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector) | ../../modules/services/cloud-connector | n/a |
| <a name="module_connector_organization_sink"></a> [connector\_organization\_sink](#module\_connector\_organization\_sink) | ../../modules/infrastructure/organization_sink | n/a |
| <a name="module_pubsub_http_subscription"></a> [pubsub\_http\_subscription](#module\_pubsub\_http\_subscription) | ../../modules/infrastructure/pubsub_subscription | n/a |
| <a name="module_secure_secrets"></a> [secure\_secrets](#module\_secure\_secrets) | ../../modules/infrastructure/secrets | n/a |

## Resources

| Name | Type |
|------|------|
| [google_organization_iam_custom_role.org_gcr_image_puller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_member.organization_image_puller](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_service_account.connector_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_organization.org](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |
| [google_projects.all_projects](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |
| [sysdig_secure_connection.current](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_connection) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization_domain"></a> [organization\_domain](#input\_organization\_domain) | Organization domain. e.g. sysdig.com | `string` | n/a | yes |
| <a name="input_benchmark_project_ids"></a> [benchmark\_project\_ids](#input\_benchmark\_project\_ids) | Google cloud project IDs to run Benchmarks on. If empty, all organization projects will be defaulted. | `list(string)` | `[]` | no |
| <a name="input_benchmark_regions"></a> [benchmark\_regions](#input\_benchmark\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all regions by default. | `list(string)` | `[]` | no |
| <a name="input_benchmark_role_name"></a> [benchmark\_role\_name](#input\_benchmark\_role\_name) | The name of the Service Account that will be created. | `string` | `"sysdigcloudbench"` | no |
| <a name="input_deploy_benchmark"></a> [deploy\_benchmark](#input\_deploy\_benchmark) | whether benchmark module is to be deployed | `bool` | `true` | no |
| <a name="input_deploy_scanning"></a> [deploy\_scanning](#input\_deploy\_scanning) | true/false whether scanning module is to be deployed | `bool` | `false` | no |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Max number of instances for the workloads | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_repository_project_ids"></a> [repository\_project\_ids](#input\_repository\_project\_ids) | Projects were a `gcr`-named topic will be to subscribe to its repository events. If empty, all organization projects will be defaulted. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://github.com/sysdiglabs/terraform-google-secure-for-cloud).

## License

Apache 2 Licensed. See LICENSE for full details.
