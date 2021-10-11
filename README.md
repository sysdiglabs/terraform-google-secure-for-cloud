# Sysdig Secure for Cloud in GCP

Terraform module that deploys the **Sysdig Secure for Cloud** stack in **Google Cloud**.
<br/>It provides unified threat detection, compliance, forensics and analysis.

There are three major components:

* **Cloud Threat Detection**: Tracks abnormal and suspicious activities in your cloud environment based on Falco language. Managed through [cloud-connector module](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector).
<br/><br/>
* **CSPM/Compliance**: It evaluates periodically your cloud configuration, using Cloud Custodian, against some benchmarks and returns the results and remediation you need to fix. Managed through [cloud-bench module](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-bench).
  <br/><br/>
* **Cloud Scanning**: Automatically scans all container images pushed to the registry or as soon a new task which involves a container is spawned in your account.Managed through [cloud-scanning module](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-scanning).
  <br/><br/>

For other Cloud providers check: [AWS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud), [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)

<br/>

## Prerequisites
The following GCP APIs **must** be enabled to deploy resources correctly for:

##### Cloud Connector
* [Cloud Pub/Sub API](https://console.cloud.google.com/marketplace/product/google/pubsub.googleapis.com)
* [Cloud Run API](https://console.cloud.google.com/marketplace/product/google/run.googleapis.com)
* [Eventarc API](https://console.cloud.google.com/marketplace/product/google/eventarc.googleapis.com)

##### Cloud Scanning
* [Cloud Pub/Sub API](https://console.cloud.google.com/marketplace/product/google/pubsub.googleapis.com)
* [Cloud Run API](https://console.cloud.google.com/marketplace/product/google/run.googleapis.com)
* [Eventarc API](https://console.cloud.google.com/marketplace/product/google/eventarc.googleapis.com)
* [Secret Manger API](https://console.cloud.google.com/marketplace/product/google/secretmanager.googleapis.com)
* [Cloud Build API](https://console.cloud.google.com/marketplace/product/google/cloudbuild.googleapis.com)
* [Identity and access management API](https://console.cloud.google.com/marketplace/product/google/iam.googleapis.com)

##### Cloud Benchmarks
* [Identity and access management API](https://console.cloud.google.com/marketplace/product/google/iam.googleapis.com)
* [IAM Service Account Credentials API](https://console.cloud.google.com/marketplace/product/google/iamcredentials.googleapis.com)
* [Cloud Resource Manager API](https://console.cloud.google.com/marketplace/product/google/cloudresourcemanager.googleapis.com)
* [Security Token Service API](https://console.cloud.google.com/marketplace/product/google/sts.googleapis.com)


## Usage

### Single-Project

Sysdig workload will be deployed in the same account where user's resources will be watched.<br/>
More info in [`./examples/single-project`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/single-project)

![single-project diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/examples/single-project/diagram-single.png)

### Organization

Using an organization to collect all the AuditLogs.
More info in [`./examples/organization`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/organization)

![organization diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/examples/organization/diagram-org.png)

### Self-Baked

If no [examples](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples) fit your use-case, be free to call desired modules directly.

In this use-case we will ONLY deploy cloud-bench, into the target account, calling modules directly

```terraform
provider "google" {
  project = "PROJECT-ID"
  region = "REGION"
}

provider "google-beta" {
  project = "PROJECT-ID"
  region = "REGION"
}

provider "sysdig" {
  sysdig_secure_api_token  = "00000000-1111-2222-3333-444444444444"
}

module "cloud_bench" {
  source      = "sysdiglabs/secure-for-cloud/google//modules/services/cloud-bench"
}

```
See [inputs summary](#inputs) or main [module `variables.tf`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/variables.tf) file for more optional configuration.

To run this example you need have your google cloud profile configured:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

Notice that:
* This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore


<br/><br/>
## Troubleshooting

- Q1: Getting "Error creating WorkloadIdentityPool: googleapi: Error 409: Requested entity already exists"<br/>
  A1: This is default behaviour we cannot control
  https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers#delete-pool
    > You can undelete a pool for up to 30 days after deletion. After 30 days, deletion is permanent. Until a pool is permanently deleted, you cannot reuse its   name when creating a new workload identity pool.<br/>

  S1: Use the `naming_prefix` input variable to create a differet workload identity federation.
  ```bash
  # re-activate
  $ gcloud iam workload-identity-pools undelete sysdigcloud  --location=global

  # import to terraform state
  $ terraform import module.secure-for-cloud_example_single-project.module.cloud_bench.google_iam_workload_identity_pool.pool sysdigcloud
  $ terraform import module.secure-for-cloud_example_single-project.module.cloud_bench.google_iam_workload_identity_pool_provider.pool_provider sysdigcloud/sysdigcloud
   ```



<br/><br/>
## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
