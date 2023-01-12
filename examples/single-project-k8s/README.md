# Sysdig Secure for Cloud in GCP<br/>[ Example :: Single-Project on Kubernetes Cluster ]

Deploy Sysdig Secure for Cloud in a provided existing Kubernetes Cluster.

- Sysdig **Helm** [cloud-connector chart](https://charts.sysdig.com/charts/cloud-connector/) will be used to deploy threat-detection and scanning features
  <br/>Because these charts require specific GCP credentials to be passed by parameter, a new service account + key will be created
  within the project. See [`credentials.tf`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/single-project-k8s/credentials.tf)
- Used architecture is similar to [single-project](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/single-project) but changing Cloud Run <---> with an existing K8s
- Contrary to non-k8s compute deployment for GCP where events are pushed to an exposed HTTP endpoint of the cloudrun task vía event-arc trigger, on k8s events are pulled from a queue configured with a pubsub model.

### Notice
* All the required resources and workloads will be run **under the same GCP project**.
* **[Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/) is not available** in this example yet.
* This example will create resources that **cost money**. Run `terraform destroy` when you don't need them anymore.


## Prerequisites

Minimum requirements:

1. Configure [Terraform **GCP** Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
2. Configure [**Helm** Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) for **Kubernetes** cluster
3. **Sysdig** Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

## Usage

For quick testing, use this snippet on your terraform files

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

provider "google-beta" {
  project = "<PROJECT_ID>"
  region  = "<REGION_ID>; ex. us-central1"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "secure_for_cloud_gcp_single_project_k8s" {
  source = "sysdiglabs/secure-for-cloud/google//examples/single-project-k8s"
}
```

See [inputs summary](#inputs) or module module [`variables.tf`](./variables.tf) file for more optional configuration.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.21.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.21.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.3.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.48.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.8.0 |
| <a name="provider_sysdig"></a> [sysdig](#provider\_sysdig) | 0.5.46 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_bench"></a> [cloud\_bench](#module\_cloud\_bench) | ../../modules/services/cloud-bench | n/a |
| <a name="module_cloud_build_permission"></a> [cloud\_build\_permission](#module\_cloud\_build\_permission) | ../../modules/infrastructure/cloud_build_permission | n/a |
| <a name="module_connector_project_sink"></a> [connector\_project\_sink](#module\_connector\_project\_sink) | ../../modules/infrastructure/project_sink | n/a |
| <a name="module_pubsub_http_subscription"></a> [pubsub\_http\_subscription](#module\_pubsub\_http\_subscription) | ../../modules/infrastructure/pubsub_subscription | n/a |
| <a name="module_secure_secrets"></a> [secure\_secrets](#module\_secure\_secrets) | ../../modules/infrastructure/secrets | n/a |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.event_receiver](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.connector_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.connector_sa_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [helm_release.cloud_connector](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [sysdig_secure_connection.current](https://registry.terraform.io/providers/sysdiglabs/sysdig/latest/docs/data-sources/secure_connection) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_benchmark_regions"></a> [benchmark\_regions](#input\_benchmark\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all regions by default. | `list(string)` | `[]` | no |
| <a name="input_benchmark_role_name"></a> [benchmark\_role\_name](#input\_benchmark\_role\_name) | The name of the Service Account that will be created. | `string` | `"sysdigcloudbench"` | no |
| <a name="input_cloud_connector_image"></a> [cloud\_connector\_image](#input\_cloud\_connector\_image) | Cloud-connector image to deploy | `string` | `"quay.io/sysdig/cloud-connector"` | no |
| <a name="input_deploy_benchmark"></a> [deploy\_benchmark](#input\_deploy\_benchmark) | whether benchmark module is to be deployed | `bool` | `true` | no |
| <a name="input_deploy_scanning"></a> [deploy\_scanning](#input\_deploy\_scanning) | true/false whether scanning module is to be deployed | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Suffix to be assigned to all created resources. Modify this value in case of conflict / 409 error to bypass Google soft delete issues | `string` | `"sfc"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
