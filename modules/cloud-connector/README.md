# Cloud Connector deploy in GCP Module

This repository contains a Module for how to deploy the Cloud Connector in the Google Cloud Platform as a Cloud Run
deployment that will detect events in your infrastructure.

## Usage

```hcl
module "cloud_connector_gcp" {
  source = "sysdiglabs/cloudvision/google/modules/cloud-connector"

  project_name       = "project-name"
  secure_api_token   = "00000000-1111-2222-3333-444444444444"
  bucket_config_name = "cloud-connector-config-bucket"
  config_content     = <<EOF
rules:
  - directory:
      path: ./rules
  - secure:
      url: https://secure.sysdig.com
ingestors:
  - auditlog:
      project: project-name
      interval: 10m
notifiers:
  - secure:
      url: https://secure.sysdig.com
  EOF

  name     = "cloud-connector"
  location = "us-central1"
}
```

## Providers

| Name   | Versions |
| ------ | -------- |
| google | >= v3.57 |

## Inputs


| Name               | Description                                                                                   | Type          | Default                                                                              | Required                             |
| ------------------ | --------------------------------------------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------ | ------------------------------------ |
| project_name       | Project name of the Google Cloud Platform                                                     | `string`      |                                                                                      | Yes                                  |
| secure_api_token   | Sysdig Secure API Token                                                                       | `string`      |                                                                                      | Yes                                  |
| bucket_config_name | Google Cloud Storage Bucket where the configuration will be saved                             | `string`      |                                                                                      | Yes                                  |
| config_content     | Contents of the configuration file to be saved in the bucket                                  | `string`      | `null`                                                                               | Only if `config_source` is not set.  |
| config_source      | Path to a file that contains the contents of the configuration file to be saved in the bucket | `string`      | `null`                                                                               | Only if `config_content` is not set. |
| verify_ssl         | Verify the SSL certificate of the Secure endpoint                                             | `bool`        | `true`                                                                               | No                                   |
| name               | Name for the Cloud Connector deployment                                                       | `string`      | `cloud-connector`                                                                    | No                                   |
| location           | Zone where the cloud connector will be deployed                                               | `string`      | `us-central1`                                                                        | No                                   |
| image_name         | Cloud Connector image to deploy                                                               | `string`      | `us-central1-docker.pkg.dev/mateo-burillo-ns/cloud-connector/cloud-connector:config` | No                                   |
| extra_envs         | Extra environment variables for the Cloud Connector instance                                  | `map(string)` | `{}`                                                                                 | No                                   |


## Authors

Module is maintained by [Sysdig](https://github.com/sysdiglabs/terraform-sysdig-cloudconnector-gcp).

## License

Apache 2 Licensed. See LICENSE for full details.
