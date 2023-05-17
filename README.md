# Sysdig Secure for Cloud in GCP

Terraform module that deploys the [**Sysdig Secure for Cloud** stack in **Google Cloud**](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-gcp/).
<br/>

Provides unified threat-detection, compliance, forensics and analysis through these major components:


* **[Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)**: Tracks abnormal and suspicious activities in your cloud environment based on Falco language. Managed through `cloud-connector` module. <br/>

* **[Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/)**: Enables the evaluation of standard compliance frameworks. Requires both modules  `cloud-connector` and `cloud-bench`. <br/>

* **[Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/)**: Automatically scans all container images pushed to the registry (GCR) and the images that run on the GCP workload (currently CloudRun). Managed through `cloud-connector`. <br/>Disabled by Default, can be enabled through `deploy_scanning` input variable parameters.<br/>

For other Cloud providers check: [AWS](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud), [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)

<br/>

## Usage

There are several ways to deploy Secure for Cloud in you GCP infrastructure,

- **[`/examples`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples)** for the most common scenarios
  - [Single Project](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/single-project/)
  - [Single Project with a pre-existing Kubernetes Cluster](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/single-project-k8s/README.md)
  - [Organizational](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/organization/README.md)
  - Many module,examples and use-cases, we provide ways to **re-use existing resources (as optionals)** in your
infrastructure. Check input summary on each example/module.
- **[`/use-cases`](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/use-cases)** with self-baked customer-specific alternative scenarios.

Find specific overall service arquitecture diagrams attached to each example/use-case.

In the long-term our purpose is to evaluate those use-cases and if they're common enough, convert them into examples to make their usage easier.

If you're unsure about what/how to use this module, please fill the [questionnaire](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/use-cases/_questionnaire.md) report as an issue and let us know your context, we will be happy to help.


### Notice
* [GCP regions](https://cloud.google.com/compute/docs/regions-zones/#available)
  * Do not confuse required `region` with GCP location or zone. [Identifying a region or zone](https://cloud.google.com/compute/docs/regions-zones/#identifying_a_region_or_zone)
* All Sysdig Secure for Cloud features but [Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/) are enabled by default. You can enable it through `deploy_scanning` input variable parameter of each example.<br/>
* For **free subscription** users, beware that organizational examples may not deploy properly due to the [1 cloud-account limitation](https://docs.sysdig.com/en/docs/administration/administration-settings/subscription/#cloud-billing-free-tier). Open an Issue so we can help you here!
* This example will create resources that **cost money**. Run `terraform destroy` when you don't need them anymore.
  * For a normal load, it should be <150$/month aprox.
  * [Cloud Logging API](https://cloud.google.com/service-usage/docs/enabled-service#default) is activated by default so no extra cost here
  * Cloud Run instance comes as the most expensive service. Default [cpu/memory specs](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/modules/services/cloud-connector/variables.tf#L73-L83), for an ingestion of 35KK events/hour, for 2 instances 24x7 usage
  * Cloud Run ingests events from a pub/sub topic, with no retention. It's cost is quite descpreciable, but you can check with the calculator based on the events of the  Log Explorer console and 4KB of size per event aprox.<br/>Beware that the logs we consume are scoped to the projects, and we exclude kubernetes events `logName=~"^projects/SCOPED_PROJECT_OR_ORG/logs/cloudaudit.googleapis.com"`
<br/>

## Prerequisites

Your user **must** have following **roles** in your GCP credentials
* _Owner_
* _Organization Admin_ (organizational usage only)

### Google Cloud CLI Authentication
To authorize the cloud CLI to be used by Terraform check the following [Terraform Google Provider docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#configuring-the-provider)

#### Use a Service Account

Instead of using a user, you can also deploy the module using a Service Account (SA). In order to create a SA for the organization, you need to go
to one of your organization projects and create a SA.
This SA must have been granted with _Organization Admin_ role. Additionally, you should allow your user to be able to use this SA.

| SA role         | SA user permissions     |
|--------------|-----------|
| ![Service Account Role](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/resources/sa-role.jpeg) | ![Service Account User](https://raw.githubusercontent.com/sysdiglabs/terraform-google-secure-for-cloud/master/resources/sa-user.jpeg)    |

### APIs

Besides, the following GCP **APIs must be enabled** ([how do I check it?](#q-how-can-i-check-enabled-api-services)) depending on the desired feature:

##### Cloud Connector
* [Cloud Pub/Sub API](https://console.cloud.google.com/marketplace/product/google/pubsub.googleapis.com)
* [Cloud Run API](https://console.cloud.google.com/marketplace/product/google/run.googleapis.com)
* [Eventarc API](https://console.cloud.google.com/marketplace/product/google/eventarc.googleapis.com)

##### Cloud Scanning
* [Cloud Pub/Sub API](https://console.cloud.google.com/marketplace/product/google/pubsub.googleapis.com)
* [Cloud Run API](https://console.cloud.google.com/marketplace/product/google/run.googleapis.com)
* [Eventarc API](https://console.cloud.google.com/marketplace/product/google/eventarc.googleapis.com)
* [Secret Manager API](https://console.cloud.google.com/marketplace/product/google/secretmanager.googleapis.com)
* [Cloud Build API](https://console.cloud.google.com/marketplace/product/google/cloudbuild.googleapis.com)
* [Identity and access management API](https://console.cloud.google.com/marketplace/product/google/iam.googleapis.com)
* [Recommendations API](https://console.developers.google.com/apis/api/recommender.googleapis.com)

##### Cloud Benchmarks
* [Identity and access management API](https://console.cloud.google.com/marketplace/product/google/iam.googleapis.com)
* [IAM Service Account Credentials API](https://console.cloud.google.com/marketplace/product/google/iamcredentials.googleapis.com)
* [Cloud Resource Manager API](https://console.cloud.google.com/marketplace/product/google/cloudresourcemanager.googleapis.com)
* [Security Token Service API](https://console.cloud.google.com/marketplace/product/google/sts.googleapis.com)
* [Cloud Asset API](https://console.cloud.google.com/marketplace/product/google/cloudasset.googleapis.com)


<br/>

## Confirm the Services are Working

Check official documentation on [Secure for cloud - GCP, Confirm the Services are working](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-gcp/#confirm-the-services-are-working)

### Forcing Events - Threat Detection

Choose one of the rules contained in an activated Runtime Policies for GCP, such as `Sysdig GCP Activity Logs` policy and execute it in your GCP account.
ex.: Create an alert (Monitoring > Alerting > Create policy). Delete it to prompt the event.

Remember that in case you add new rules to the policy you need to give it time to propagate the changes.

In the `cloud-connector` logs you should see similar logs to these
> An alert has been deleted (requesting user=..., requesting IP=..., resource name=projects/test/alertPolicies/3771445340801051512)

In `Secure > Events` you should see the event coming through, but beware you may need to activate specific levels such as `Info` depending on the rule you're firing.

Alternatively, use Terraform example module to trigger **GCP Update, Disable or Delete Sink** event can be found on [examples/trigger-events ](https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/trigger-events)

### Forcing Events - Image Scanning

- For Repository image scanning, upload an image to a new Repository in a Artifact Registry. Follow repository `Setup Instructions` provided by GCP
    ```bash
    $ docker tag IMAGE:VERSION REPO_REGION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE:latest
    $ docker push REPO_REGION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE:latest
    ````

- For CloudRun image scanning, deploy a runner.

It may take some time, but you should see logs detecting the new image in the `cloud-connector` logs, similar to these
> An image has been pushed to GCR registry (project=..., tag=europe-west2-docker.pregionkg.dev/test-repo/alpine/alpine:latest, digest=europe-west2-docker.pkg.dev/test-repo/alpine/alpine@sha256:be9bdc0ef8e96dbc428dc189b31e2e3b05523d96d12ed627c37aa2936653258c)
> Starting GCR scanning for 'europe-west2-docker.pkg.dev/test-repo/alpine/alpine:latest

And a CloudBuild being launched successfully.

<br/>

## Troubleshooting

### Q: Module does not find project ID
A: Verify you're ussing project ID, and not name or number. https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin

### Q: How can I check enabled API Services?
A: On your Google Cloud account, search for "APIs & Services > Enabled APIs & Services" or run following command
```bash
$ gcloud services list --enabled
```

### Q: Getting  "googleapi: 403 ***"
A: This may happen because permissions are not enough, API services were not correctly enabled, or you're not correctly authenticated for terraform google prolvider.
<br/>S: Verify [permissions](#prerequisites), [api-services](#apis), and that the [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#configuring-the-provider) authentication has been correctly setup.
You can also launch the following terraform manifest to check whether you're authenticated with what you expect

```
data "google_client_openid_userinfo" "me" {
}

output "me" {
  value = data.google_client_openid_userinfo.me.*
}
```

### Q: In organizaitonal setup, Compliance trust-relationship is not being deployed on our projects

As for 2023 April, organizations with projects under organizational unit folders, is supported with the
[organizational compliance example](./examples/organization-org_compliance)

<br/>S: If you want to target specific projects, you can still use the `benchmark_project_ids` parameter so you can define
the projects where compliance role is to be deployed explicitly.
<br/>You can use the [fetch-gcp-rojects.sh](./resources/fetch-gcp-projects.sh) utility to list organization member projects
<br/>Let us know if this workaround won't be enough, and we will work on implementing a solution.

### Q: Compliance is not working. How can I check everything is properly setup

A: On your GCP infrastructure, per-project where Comliance has been setup, check following points<br/>
1. there is a Workload Identity Pool and associated Workload Identity Pool Provider configured, which must have an ID of `sysdigcloud` (display name doesn't matter)
2. the pool should have a connected service account with the name `sfcsysdigcloudbench`, with the email `sfcsysdigcloudbench@PROJECTID.iam.gserviceaccount.com`
3. this serviceaccount should allow access to the following format `principalset: principalSet://iam.googleapis.com/projects/<PROJECTID>/locations/global/workloadIdentityPools/sysdigcloud/attribute.aws_role/arn:aws:sts::***:assumed-role/***`
4. the serviceaccount should have the `viewer role` on the target project, as well as a custom role containing the "storage.buckets.getIamPolicy", "bigquery.tables.list", "cloudasset.assets.listIamPolicy" and "cloudasset.assets.listResource" permissions
5. the pool provider should allow access to Sysdig's  trusted identity, retrieved through
  ```
  $ curl https://<SYSDIG_SECURE_URL>/api/cloud/v2/gcp/trustedIdentity \
  --header 'Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>'
  ```

### Q: Getting "Error creating Service: googleapi: got HTTP response code 404" "The requested URL /serving.knative.dev/v1/namespaces/***/services was not found on this server"

```
"module.secure-for-cloud_example_organization.module.cloud_connector.goo
gle_cloud_run_service.cloud_connector" error: Error creating Service: googleapi: got HTTP response code 404 with
…
  <p><b>404.</b> <ins>That’s an error.</ins>
  <p>The requested URL <code>/apis/serving.knative.dev/v1/namespaces/****/services</code> was not found on this server.  <ins>That’s all we know.</ins>
```
A: This error is given by the Terraform GCP provider when an invalid region is used.
<br/>S: Use one of the available [GCP regions](https://cloud.google.com/compute/docs/regions-zones/#available). Do not confuse required `region` with GCP location or zone. [Identifying a region or zone](https://cloud.google.com/compute/docs/regions-zones/#identifying_a_region_or_zone)

### Q: Error  because it cannot resolve the address below, "https://-run.googleapis.com/apis/serving.knative.dev"
A: GCP region was not provided in the provider block

### Q: Why do we need `google-beta` provider?

A: Some resources we use, such as the [`google_iam_workload_identity_pool_provider`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) are only available in the beta version.<br/>

### Q: Getting "Error creating WorkloadIdentityPool: googleapi: Error 409: Requested entity already exists"<br/>
A: Currently Sysdig Backend does not support dynamic WorkloadPool and it's name is fixed to `sysdigcloud`.
<br/>Moreover, Google, only performs a soft-deletion of this resource.
https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers#delete-pool
> You can undelete a pool for up to 30 days after deletion. After 30 days, deletion is permanent. Until a pool is permanently deleted, you cannot reuse its   name when creating a new workload identity pool.<br/>

<br/>S: For the moment, federation workload identity pool+provider have fixed name.
Therea are several options here

- For single-account, in case you want to reuse it, you can make use of the `reuse_workload_identity_pool` attribute available in some
examples.
- For organizational setups, you can make use of a single workload-identity for all the organization, with the [/organization-org_compliance](./examples/organization-org_compliance)
- Alternatively, you can reactivate and import it, into your terraform state manually.
  ```bash
  # re-activate pool and provider
  $ gcloud iam workload-identity-pools undelete sysdigcloud  --location=global
  $ gcloud iam workload-identity-pools providers undelete sysdigcloud --workload-identity-pool="sysdigcloud" --location=global

  # import to terraform state
  # for this you have to adapt the import resource to your specific usage
  # ex.: for single-project, input your project-id
  $ terraform import 'module.secure-for-cloud_example_single-project.module.cloud_bench[0].module.trust_relationship["<PROJECT_ID>"].google_iam_workload_identity_pool.pool' <PROJECT_ID>/sysdigcloud
  $ terraform import 'module.secure-for-cloud_example_single-project.module.cloud_bench[0].module.trust_relationship["<PROJECT_ID>"].google_iam_workload_identity_pool_provider.pool_provider' <PROJECT_ID>/sysdigcloud/sysdigcloud

  # ex.: for organization example you should change its reference too, per project
  $ terraform import 'module.secure-for-cloud_example_organization.module.cloud_bench[0].module.trust_relationship["<PROJECT_ID>"].google_iam_workload_identity_pool.pool' <PROJECT_ID>/sysdigcloud
  $ terraform import 'module.secure-for-cloud_example_organization.module.cloud_bench[0].module.trust_relationship["<PROJECT_ID>"].google_iam_workload_identity_pool_provider.pool_provider' <PROJECT_ID>/sysdigcloud/sysdigcloud
   ```

   The import resource to use, is the one pointed out in your terraform plan/apply error messsage
   ```
   -- for
  Error: Error creating WorkloadIdentityPool: googleapi: Error 409: Requested entity already exists
    with module.secure-for-cloud_example_organization.module.cloud_bench[0].module.trust_relationship["org-child-project-1"].google_iam_workload_identity_pool.pool,
    on .... in resource "google_iam_workload_identity_pool" "pool":
    resource "google_iam_workload_identity_pool" "pool" {

   -- use
   ' module.secure-for-cloud_example_organization.module.cloud_bench[0].module.trust_relationship["org-child-project-1"].google_iam_workload_identity_pool.pool' as your import resource

   -- such as
   $ terraform import 'module.secure-for-cloud_example_organization.module.cloud_bench[0].module.trust_relationship["org-child-project-1"].google_iam_workload_identity_pool.pool' 'org-child-project-1/sysdigcloud'

   ```

   Note: if you're using terragrunt, run `terragrunt import`

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

Note: if you're using terragrunt, run `terragrunt import`

### Q: Getting "Cloud Run error: Container failed to start. Failed to start and then listen on the port defined by the PORT environment variable."
A: If cloud-connector cloud run module cannot start it will give this error. The error is given by the health-check system, it's not specific to its PORT per-se
<br/>S: Verify possible logs before the deployment crashes. Could be limitations due to Sysdig license (expired trial subscription or free-tier usage where cloud-account limit has been surpassed)

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


### Q-Scanning: Scanning does not seem to work<br/>
A: Verify that `gcr` topic exists. If `create_gcr_topic` is set to false and `gcr` topic is not found, the GCR scanning is omitted and won't be deployed. For more info see GCR PubSub topic.
<br/><br/>


## Upgrading

1. Uninstall previous deployment resources before upgrading
  ```
  $ terraform destroy
  ```

2. Upgrade the full terraform example with
  ```
  $ terraform init -upgrade
  $ terraform plan
  $ terraform apply
  ```

- If the event-source is created throuh SFC, some events may get lost while upgrading with this approach. however, if the cloudtrail is re-used (normal production setup) events will be recovered once the ingestion resumes.

- If required, you can upgrade cloud-connector component by restarting the task (stop task). Because it's not pinned to an specific version, it will download the `latest` one.

<br/>

## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
