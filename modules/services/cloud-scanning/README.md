# Cloud Scanning deploy in GCP Module

This repository contains a Module for how to deploy the Cloud Scanning in the Google Cloud Platform as a Cloud Run
deployment that trigger image scans based on changes in your infrastructure.

## Usage

```hcl
module "cloud_scanning_gcp" {
  source = "sysdiglabs/secure-for-cloud/google/services/cloud-scanning"

  create_gcr_topic        = true
  # Set to "false" if there's an existing PubSub topic called "gcr"
  sysdig_secure_api_token = "00000000-1111-2222-3333-444444444444"
  sysdig_secure_endpoint  = "https://secure.sysdig.com"
}
```

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

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service.cloud_scanning](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service) | resource |
| [google_cloud_run_service_iam_member.run_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_eventarc_trigger.gcr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/eventarc_trigger) | resource |
| [google_eventarc_trigger.trigger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/eventarc_trigger) | resource |
| [google_project_iam_member.builder](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.event_receiver](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.service_account_user_itself](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_topic.gcr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_pubsub_topic.gcr](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/pubsub_topic) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_scanning_sa_email"></a> [cloud\_scanning\_sa\_email](#input\_cloud\_scanning\_sa\_email) | Cloud Connector service account email | `string` | n/a | yes |
| <a name="input_create_gcr_topic"></a> [create\_gcr\_topic](#input\_create\_gcr\_topic) | Deploys a PubSub topic called `gcr` as part of this stack, which is needed for GCR scanning. Set to `true` only if it doesn't exist yet. If this is not deployed, and no existing `gcr` topic is found, the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic). | `bool` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | organizational member project ID where the secure-for-cloud workload is going to be deployed | `string` | n/a | yes |
| <a name="input_scanning_pubsub_topic_id"></a> [scanning\_pubsub\_topic\_id](#input\_scanning\_pubsub\_topic\_id) | Cloud Scanning PubSub single account topic id | `string` | n/a | yes |
| <a name="input_secure_api_token_secret_id"></a> [secure\_api\_token\_secret\_id](#input\_secure\_api\_token\_secret\_id) | Sysdig Secure API token secret id | `string` | n/a | yes |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig's Secure API Token | `string` | n/a | yes |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig's Secure API URL | `string` | n/a | yes |
| <a name="input_extra_envs"></a> [extra\_envs](#input\_extra\_envs) | Extra environment variables for the Cloud Scanning instance | `map(string)` | `{}` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Cloud scanning image to deploy | `string` | `"gcr.io/mateo-burillo-ns/cloud-scanning:latest"` | no |
| <a name="input_location"></a> [location](#input\_location) | Zone where the cloud scanning will be deployed | `string` | `"us-central1"` | no |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Max number of instances for the Cloud Scanning | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_verify_ssl"></a> [verify\_ssl](#input\_verify\_ssl) | Verify the SSL certificate of the Secure endpoint | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://github.com/sysdiglabs/terraform-google-cloudvision).

## License

Apache 2 Licensed. See LICENSE for full details.
