# Cloud Vision deploy in GCP Module

This repository contains a Module for how to deploy the Cloud Vision in the Google Cloud Platform with different
components deployment that will detect events in your infrastructure.

## Usage

### APIs

#### The following GCP APIs must be enabled to deply resources correctly

* CLOUD RUN API
* EVENTARC API
* SECRET MANAGER API
* CLOUD BUILD API
* IDENTIFY AND ACCESS MANAGMENT API

### Module Usage

```hcl
module "cloud_vision_gcp" {
  source = "sysdiglabs/cloudvision/google"

  location                = "us-central1"
  sysdig_secure_api_token = "00000000-1111-2222-3333-444444444444"
  create_gcr_topic        = true
  # Set to "false" if the PubSub topic called "gcr" already exists.
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > = 0.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | > = 3.67.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector) | ./modules/cloud-connector |  |
| <a name="module_cloud_scanning"></a> [cloud\_scanning](#module\_cloud\_scanning) | ./modules/cloud-scanning |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudconnector_deploy"></a> [cloudconnector\_deploy](#input\_cloudconnector\_deploy) | Whether to deploy or not CloudConnector | `bool` | `true` | no |
| <a name="input_cloudscanning_deploy"></a> [cloudscanning\_deploy](#input\_cloudscanning\_deploy) | Whether to deploy or not CloudConnector | `bool` | `true` | no |
| <a name="input_create_gcr_topic"></a> [create\_gcr\_topic](#input\_create\_gcr\_topic) | Deploys a PubSub topic called `gcr` as part of this stack, which is needed for GCR scanning. Set to `true` if it doesn't exist yet. If this is not deployed, and no existing `gcr` topic is found, the GCR scanning is ommited and won't be deployed. For more info see [GCR PubSub topic](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic). | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | Zone where the stack will be deployed | `string` | `"us-central1"` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Naming prefix for all the resources created | `string` | `""` | no |
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig's Secure API Token | `string` | n/a | yes |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://github.com/sysdiglabs/terraform-google-cloudvision).

## License

Apache 2 Licensed. See LICENSE for full details.
