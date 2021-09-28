# Sysdig Secure for Cloud in GCP

Terraform module that deploys the **Sysdig Secure for Cloud** stack in **Google Cloud**.
<br/>It provides unified threat detection, compliance, forensics and analysis.

There are three major components:

* **Cloud Threat Detection**: Tracks abnormal and suspicious activities in your cloud environment based on Falco language. Managed through [cloud-connector module](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector).<br/>

* **CSPM/Compliance**: It evaluates periodically your cloud configuration, using Cloud Custodian, against some benchmarks and returns the results and remediation you need to fix. Managed through [cloud-bench module](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-bench).<br/>

* **Cloud Scanning**: Automatically scans all container images pushed to the registry or as soon a new task which involves a container is spawned in your account.Managed through [cloud-scanning module](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-scanning).<br/>

For other Cloud providers check: [AWS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud), [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)

<br/>

## Usage

### APIs

The following GCP APIs **must** be enabled to deply resources correctly

> ##### APIs Required by Cloud Connector
>* Cloud Run API
>* Eventarc API

> ##### APIs Required by Cloud Scanning
>* Cloud Run API
>* Eventarc API
>* Secret Manger API
>* Cloud Build API
>* Identity and access management API

> ##### APIs Required by Cloud Benchmarks
>* Identity and access management API
>* IAM Service Account Credentials API
>* Cloud Resource Manager API
>* Security Token Service API

### Single-Project

Sysdig workload will be deployed in the same account where user's resources will be watched.<br/>
More info in [`./examples/single-project`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/single-account)

![single-project diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/examples/organization/diagram-single.png)

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
