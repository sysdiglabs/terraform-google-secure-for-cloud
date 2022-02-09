# Sysdig Secure for Cloud in GCP<br/>[ Example :: Single-Project ]
This example helps to trigger GCP Events. Cloud connector stack is required to be able to generate events.
After applying, this will create a new sink and assign it to a new pub/sub topic. **GCP Update, Disable or Delete Sink** event will prompt once the module is destroyed.

## Prerequisites

Minimum requirements:
1. Deploy Cloud Connector Stack on GCP.
2. Configure Terraform GCP Provider.

## Usage

For quick testing, use this snippet on your terraform files

```terraform
provider "google" {
   project = "<PROJECT_ID>"
   region  = "<REGION_ID>; ex. us-central-1"
}

module "secure-for-cloud_trigger_events" {
  source = "sysdiglabs/secure-for-cloud/google//examples/trigger-events"
  project_id = "<PROJECT_ID>"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.67.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 3.67.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 3.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_logging_project_sink.project_sink](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_pubsub_topic.trigger_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Organization member project ID where the secure-for-cloud workload is going to be deployed | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://github.com/sysdiglabs/terraform-google-cloudvision).

## License

Apache 2 Licensed. See LICENSE for full details.
