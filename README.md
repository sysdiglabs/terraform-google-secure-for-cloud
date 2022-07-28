# Sysdig Secure for Cloud in GCP

Terraform module that deploys the [**Sysdig Secure for Cloud** stack in **Google Cloud**](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-gcp/).
<br/>

Provides unified threat-detection, compliance, forensics and analysis through these major components:


* **[Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)**: Tracks abnormal and suspicious activities in your cloud environment based on Falco language. Managed through `cloud-connector` module. <br/>

* **[Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/)**: Enables the evaluation of standard compliance frameworks. Requires both modules  `cloud-connector` and `cloud-bench`. <br/>

* **[Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/)**: Automatically scans all container images pushed to the registry (GCR) and the images that run on the GCP workload (currently CloudRun). Managed through `cloud-connector`. <br/>Disabled by Default, can be enabled through `deploy_scanning` input variable parameters.<br/>

For other Cloud providers check: [AWS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud), [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)


## Notice
* [GCP regions](https://cloud.google.com/compute/docs/regions-zones/#available)
* All Sysdig Secure for Cloud features but [Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/) are enabled by default. You can enable it through `deploy_scanning` input variable parameter of each example.<br/>
* This example will create resources that **cost money**. Run `terraform destroy` when you don't need them anymore.
* For **free subscription** users, beware that organizational examples may not deploy properly due to the [1 cloud-account limitation](https://docs.sysdig.com/en/docs/administration/administration-settings/subscription/#cloud-billing-free-tier). Open an Issue so we can help you here!
<br/>

## Prerequisites

Your user **must** have following **roles** in your GCP credentials
* _Owner_
* _Organization Admin_ (organizational usage only)

### Use a Service Account

Instead of using a user, you can also deploy the module using a Service Account (SA). In order to create a SA for the organization, you need to go
to one of your organization projects and create a SA. 
This SA must have been granted with _Organization Admin_ role. Additionally, you should allow your user to be able to use this SA.

| SA role         | SA user permissions     | 
|--------------|-----------|
| ![Service Account Role](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/resources/sa-role.jpeg) | ![Service Accouynt User](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/resources/sa-user.jpeg)    | 

### APIs
Besides, the following GCP **APIs must be enabled** to deploy resources correctly for:

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

If you're unsure about what/how to use this module, please fill the [questionnaire](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/use-cases/_questionnaire.md) report as an issue and let us know your context, we will be happy to help and improve our module.


### - Single-Project

Sysdig workload will be deployed in the same account where user's resources will be watched.<br/>
More info in [`./examples/single-project`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/single-project)

![single-project diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/examples/single-project/diagram-single.png)

### - Single-Project with a pre-existing Kubernetes Cluster

If you already own a Kubernetes Cluster on GCP, you can use it to deploy Sysdig Secure for Cloud, instead of default CloudRun.<br/>
More info in [`./examples/single-project-k8s`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/single-project-k8s)


### - Organization

Using an organization to collect all the AuditLogs.
More info in [`./examples/organization`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/organization)

![organization diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/examples/organization/diagram-org.png)

### - Self-Baked

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
  sysdig_secure_url         = "<SYSDIG_SECURE_URL>"
  sysdig_secure_endpoint    = "<SYSDIG_SECURE_API_TOKEN>"
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

<br/><br/>


## Forcing Events

**Threat Detection**

Terraform example module to trigger **GCP Update, Disable or Delete Sink** event can be found on [examples/trigger-events ](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/trigger-events)

In another case, you can do it manually. Choose one of the rules contained in the `GCP Best Practices` policy and execute it in your GCP account.
ex.: Create an alert (Monitoring > Alerting > Create policy). Delete it to prompt the event.

Remember that in case you add new rules to the policy you need to give it time to propagate the changes.

In the `cloud-connector` logs you should see similar logs to these
> An alert has been deleted (requesting user=..., requesting IP=..., resource name=projects/test/alertPolicies/3771445340801051512)

**Image Scanning**

- For Repository image scanning, upload an image to a new Repository in a Artifact Registry. Follow repository `Setup Instructions` provided by GCP
    ```bash
    $ docker tag IMAGE:VERSION REPO_REGION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE:latest
    $ docker push REPO_REGION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE:latest
    ````

- For CloudRun image scanning, deploy a runner.

It may take some time, but you should see logs detecting the new image in the `cloud-connector` logs, similar to these
> An image has been pushed to GCR registry (project=..., tag=europe-west2-docker.pkg.dev/test-repo/alpine/alpine:latest, digest=europe-west2-docker.pkg.dev/test-repo/alpine/alpine@sha256:be9bdc0ef8e96dbc428dc189b31e2e3b05523d96d12ed627c37aa2936653258c)
> Starting GCR scanning for 'europe-west2-docker.pkg.dev/test-repo/alpine/alpine:latest

And a CloudBuild being launched successfully.



## Troubleshooting

### Q: Getting "Error creating Service: googleapi: got HTTP response code 404" "The requested URL /serving.knative.dev/v1/namespaces/xxx/services was not found on this server"

```
"module.secure-for-cloud_example_organization.module.cloud_connector.goo
gle_cloud_run_service.cloud_connector" error: Error creating Service: googleapi: got HTTP response code 404 with
…
  <p><b>404.</b> <ins>That’s an error.</ins>
  <p>The requested URL <code>/apis/serving.knative.dev/v1/namespaces/prj-c-sysdig-aeee/services</code> was not found on this server.  <ins>That’s all we know.</ins>
```
A: This error is given by the Terraform GCP provider when an invalid region is used.
<br/>S: Use one of the available regions https://cloud.google.com/compute/docs/regions-zones/#available


### Q: Why do we need `google-beta` provider?

A: Some resources we use, such as the [`google_iam_workload_identity_pool_provider`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) are only available in the beta version.<br/>

### Q: Getting "Error creating WorkloadIdentityPool: googleapi: Error 409: Requested entity already exists"<br/>
A: Currently Sysdig Backend does not support dynamic WorkloadPool and it's name is fixed to `sysdigcloud`.
<br/>Besides, Google, only performs a soft-deletion of this resource.
https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers#delete-pool
> You can undelete a pool for up to 30 days after deletion. After 30 days, deletion is permanent. Until a pool is permanently deleted, you cannot reuse its   name when creating a new workload identity pool.<br/>

<br/>S: For the moment, federation workload identity pool+provider have fixed name. In case you want to reuse it, you can reactivate and import it, into your terraform state manually.
```bash
# re-activate pool and provider
$ gcloud iam workload-identity-pools undelete sysdigcloud  --location=global
$ gcloud iam workload-identity-pools providers undelete sysdigcloud --workload-identity-pool="sysdigcloud" --location=global

# import to terraform state
# for this you have to adapt the import resource to your specific usage
# ex.: for single-project, input your project-id
$ terraform import 'module.secure-for-cloud_example_single-project.module.cloud_bench[0].module.trust_relationship["<YOUR_PROJECT_ID>"].google_iam_workload_identity_pool.pool' sysdigcloud
$ terraform import 'module.secure-for-cloud_example_single-project.module.cloud_bench[0].module.trust_relationship["<YOUR_PROJECT_ID>"].google_iam_workload_identity_pool_provider.pool_provider' sysdigcloud/sysdigcloud

# ex.: for organization example you should change its reference too, per project
$ terraform import 'module.secure-for-cloud_example_organization.module.cloud_bench[0].module.trust_relationship["<YOUR_PROJECT_ID>"].google_iam_workload_identity_pool.pool' sysdigcloud
$ terraform import 'module.secure-for-cloud_example_organization.module.cloud_bench[0].module.trust_relationship["<YOUR_PROJECT_ID>"].google_iam_workload_identity_pool_provider.pool_provider' sysdigcloud/sysdigcloud
 ```

### Q: Getting "Error creating Topic: googleapi: Error 409: Resource already exists in the project (resource=gcr)"
```text
│ Error: Error creating Topic: googleapi: Error 409: Resource already exists in the project (resource=gcr).
│
│   with module.sfc_example_single_project.module.pubsub_http_subscription.google_pubsub_topic.topic[0],
│   on ../../../modules/infrastructure/pubsub_push_http_subscription/main.tf line 10, in resource "google_pubsub_topic" "topic":
│   10: resource "google_pubsub_topic" "topic" {
```
A: This error happens due to a GCP limitation where only a single topic named `gcr` can exist. This name is [gcp hardcoded](https://cloud.google.com/container-registry/docs/configuring-notifications#create_a_topic) and is the one we used to detect images pushed to the registry.
<br/>S: If the topic already exists, you can import it in your terraform state, BUT BEWARE that once you call destroy it will be removed.

```terraform
$ terraform import 'module.sfc_example_single_project.module.pubsub_http_subscription.google_pubsub_topic.topic[0]' gcr
```
Contact us to develop a workaround for this, where the topic name is to be reused.


### Q: Getting "Cloud Run error: Container failed to start. Failed to start and then listen on the port defined by the PORT environment variable."
A: If cloud-connector cloud run module cannot start it will give this error. The error is given by the health-check system, it's not specific to its PORT per-se
S: Verify possible logs before the deployment crashes. Could be limitations due to Sysdig license (expired trial subscription or free-tier usage where cloud-account limit has been surpassed)

### Q: Scanning does not seem to work<br/>
A: Verify that `gcr` topic exists. If `create_gcr_topic` is set to false and `gcr` topic is not found, the GCR scanning is omitted and won't be deployed. For more info see GCR PubSub topic.
<br/><br/>

### Q: Getting "message: Cloud Run error: Container failed to start. Failed to start and then listen on the port defined by the PORT environment variable"
A: Contrary to AWS, Terraform Google deployment requires just-started workload to start in a healthy status. If this does not happen it will fail.
<br/>S: Check your workload services (cloud run) logs to see what really failed. One common cause is a wrong Sysdig Secure API Token

### Q: Scanning, I get an error saying:
```
error starting scan runner for image ****: rpc error: code = PermissionDenied desc = Cloud Build API has not been used in project *** before or it is disabled.
Enable it by visiting https://console.developers.google.com/apis/api/cloudbuild.googleapis.com/overview?project=*** then retry.

If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry
```
A: Do as the error says and activate CloudBuild API. Check the list of all the required APIs that need to be activated per feature module.
<br/><br/>


## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
