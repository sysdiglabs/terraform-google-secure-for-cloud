# Cloud Connector deploy in GCP Module

A **Cloud Run** deployment that will detect events in your infrastructure.

## Usage

```hcl
provider "google" {
  project = "<PROJECT_ID>"
  region  = "<REGION_ID>; ex. us-central1"
}

module "cloud_connector_gcp" {
  source = "sysdiglabs/secure-for-cloud/google/services/cloud-connector"

  sysdig_secure_api_token = "00000000-1111-2222-3333-444444444444"
  sysdig_secure_endpoint  = "https://secure.sysdig.com"
  bucket_config_name      = "cloud-connector-config-bucket"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.21.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.30.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service.cloud_connector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service) | resource |
| [google_cloud_run_service_iam_member.run_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_eventarc_trigger.trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/eventarc_trigger) | resource |
| [google_project_iam_member.event_receiver](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.run_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connector_sa_email"></a> [cloud\_connector\_sa\_email](#input\_cloud\_connector\_sa\_email) | Cloud Connector service account email | `string` | n/a | yes |
| <a name="input_connector_pubsub_topic_id"></a> [connector\_pubsub\_topic\_id](#input\_connector\_pubsub\_topic\_id) | Cloud Connector PubSub single account topic id | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | organizational member project ID where the secure-for-cloud workload is going to be deployed | `string` | n/a | yes |
| <a name="input_secure_api_token_secret_id"></a> [secure\_api\_token\_secret\_id](#input\_secure\_api\_token\_secret\_id) | Sysdig Secure API token secret id | `string` | n/a | yes |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig's Secure API Token | `string` | n/a | yes |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig's Secure API URL | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Amount of CPU to reserve for cloud-connector cloud run service | `string` | `"1"` | no |
| <a name="input_deploy_scanning"></a> [deploy\_scanning](#input\_deploy\_scanning) | true/false whether scanning module is to be deployed | `bool` | `false` | no |
| <a name="input_extra_envs"></a> [extra\_envs](#input\_extra\_envs) | Extra environment variables for the Cloud Connector instance | `map(string)` | `{}` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Sysdig Owned Cloud Connector public image. GCP only allows the deployment of images that are registered in gcr.io | `string` | `"gcr.io/mateo-burillo-ns/cloud-connector:latest"` | no |
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational) | whether secure-for-cloud should be deployed in an organizational setup | `bool` | `false` | no |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Max number of instances for the Cloud Connector | `number` | `1` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Amount of memory to reserve for cloud-connector cloud run service | `string` | `"500Mi"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc-cloudconnector"` | no |
| <a name="input_verify_ssl"></a> [verify\_ssl](#input\_verify\_ssl) | Verify the SSL certificate of the Secure endpoint | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_run_service_url"></a> [cloud\_run\_service\_url](#output\_cloud\_run\_service\_url) | URL of the Cloud Run service |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://github.com/sysdiglabs/terraform-google-secure-for-cloud).

## License

Apache 2 Licensed. See LICENSE for full details.
