# Organizational - Kubernetes only (no TF) - Threat Detection and Compliance

## Use-Case explanation

### Requirements

- Organizational setup
  - Dynamic environments with projects created and destroyed on-demand
- Sysdig features: Threat-detection, Compliance (no image scanning)
- Due to dynamic nature of customer's environment, a heavy programmatically ops tooling are used (not including Terraform) .
- A summary of the required resources/permissions will be done, so they're provisioned for the Secure for Cloud feature sto work.

## Suggested Solution

### Overall Infrastructure

As a quick summary we'll need

- Organization
  - Log Router Sink
  - CloudBench Role for compliance
- Member account (sysdig compute workload)
  - PubSub to wire events from the log router into cloud-connector compute module
  - CloudBench Role for compliance
- Rest of member accounts
  - CloudBench Role for compliance

![overall infrastructure](resources/diagram-org-k8s-threat-compliance.png)

### Requirements

We suggest to
- start with secure for cloud, cloud-connector module required infrastructure wiring and deployment (this will cover threat-detection side)
- then move on to Compliance role setup

##### Cloud-Connector wiring: Log Router Sink + PubSub Topic

0. From your organization, **choose a member project** as `SYSDIG_PROJECT`
1. In `SYSDIG_PROJECT`, create a **Pub/Sub** topic (with default configuration is enough)
   - Save `SYSDIG_PUBSUB_NAME` for later <!-- iru note: is this the topic name or just the id? -->
2. In the organizational domain level, create **Logging Logs Router** Sink
   - Add as destination the Pub/Sub from previous point.
   - Choose to ingest organization and child resources
   - Set the following filter
     > logName=~"/logs/cloudaudit.googleapis.com%2Factivity$" AND -resource.type="k8s_cluster"
3. Give Sink **Permissions** to write on PubSub
   - Grab the `Writer Identity` user from the just created Sink
   - In the PubSub resource, grant `Pub/Sub Publisher` role to the Sink writer identity


#### Secure for Cloud Compute Deployment

<!--
##### k8s/CloudConnector(Threat) (to be hidden)

User should provide a k8s cluster to install CloudConnector on it.
Both self installed and GKE are valid.
-->

<!--
-- TODO. authentication howto.
- 1/first approach would be to create a SA

small explanation here https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/single-project-k8s
and code reference here https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/single-project-k8s/cloud-connector-config.tf#L21

- 2/more elegant approach to use the serviceAccount from the chart. talk with @javi
-->

Sysdig **Helm** [cloud-connector chart](https://charts.sysdig.com/charts/cloud-connector/) will be used with following parametrization

```json
-- values.yaml
logging: info
rules: []
scanners: []
sysdig:
  # Sysdig Secure URL
  url: "https://secure.sysdig.com"
  # API Token to access Sysdig Secure
  secureAPIToken: ""

# not required but would help product
telemetryDeploymentMethod: "helm_gcp_k8s_org"

ingestors:
  # Receives GCP GCR from a PubSub topic
  - gcp-gcr-pubsub:
      project: <SYSDIG_PROJECT>
      subscription: <SYSDIG_PUBSUB_NAME>
```

##### Compliance - Sysdig Side

Register on **Sysdig Secure** backend information about customer's organization projects
  - Locate your `<SYSDIG_SECURE_ENDPOINT>` and `<SYSDIG_SECURE_API_TOKEN>`. [Howto fetch ApiToken](https://docs.sysdig.com/en/docs/administration/administration-settings/user-profile-and-password/retrieve-the-sysdig-api-token/)  
  - For Sysdig Secure backend API communication [Howto use development tools](https://docs.sysdig.com/en/docs/developer-tools/), we have this [AWS provisioning script](https://github.com/sysdiglabs/aws-templates-secure-for-cloud/blob/main/utils/sysdig_cloud_compliance_provisioning.sh) too as reference, but we will explain it here too.

1. **Register Organization Projects** on Sysdig
    - For each project you want to provision for the Compliance features, we need to register them on Sysdig Secure
    ```shell
    curl "https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/accounts?includeExternalID=true\&upsert=true" \
    --header "Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>" \
    -X POST \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
          "accountId": "<GCP_PROJECT_ID>",
          "alias": "<GCP_PROJECT_ALIAS>",
          "provider": "gcp",
          "roleAvailable": true,
          "roleName": "sysdigcloudbench"
       }'
    ```
   <br/><br/>
2. Register **Benchmark Task**
    - Create a single task to scope the organization group ids to be assessed.
    - This script does not cover it, but specific regions can be scoped too. Check `Benchmarks-V2` REST-API for more detail
   ```shell
   $ curl -s "https://<SYSDIG_SECURE_ENDPOINT>/api/benchmarks/v2/tasks" \
--header "Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>" \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{
"name": "Sysdig Secure for Cloud (GCP) - Organization",
"schedule": "0 3 * * *",
"schema": "gcp_foundations_bench-1.2.0",
"scope": "gcp.projectId in ('<ORG_PROJECT_ID1',...,'<ORG_PROJECT_IDN')'",
"enabled": true
}'
    ```
3. Get **Sysdig Federation TrustedIdentity**
   - For later usage, fetch from `<TRUSTED_IDENTITY>`, the 12-digit number from the response is the AWS account ID you need to provide
    ```shell
    $ curl -s 'https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/aws/trustedIdentity' \
    --header 'Authorization: Bearer <SYSDIG_SECURE_API_TOKEN>'
    ```
   <br/><br/>
4. Get **Sysdig ExternalId**
    - For later usage, fetch `<EXTERNAL_ID>` from one of the previously registered GCP projects. All accounts will have same id.
    ```shell
    $ curl -s "https://<SYSDIG_SECURE_ENDPOINT>/api/cloud/v2/accounts/<GCP_PROJECT_ID>}?includeExternalId=true" \
    --header "Authorization: Bearer $SYSDIG_API_TOKEN" | jq ".externalId")
    ```
   <br/><br/>

##### Compliance - Customer's Side

We'll need, **for each project**

- A **Service Account** (SA) with `IAM Workload Identity Federation` on Sysdigs AWS Cloud infrastructure, to be able to assess your infrastructure Compliance
    - currently, federation is only available through AWS, but we will enable other clouds in the near-future
- **Permissions** set to the SA to be able to read customer's infrastructure

![compliance role](resources/diagram-org-k8s-threat-compliance-roles.png)


1. Create a **Custom Role** (ex.: 'Sysdig Cloud Benchmark Role') and assign to it following permissions
   - `storage.buckets.getIamPolicy`
   - `bigquery.tables.list`
   - this is required to add some more permissions that are not available in GCP builtin viewer role
2. Create a **Service Account** with the name 'sysdigcloudbench'
   - Give it GCP builtin `roles/viewer` **Viewer Role**
   - And previously created Custom Role <!-- tip: in UI: IAM & Admin -> IAM (Edit)-->


-- sysdigs arn:aws:iam::273107874544:role/us-east-1-production-secure-assume-role

3. Create a **Workload Identity Federation Provider and Pool**
   - Provider must be created for `aws` provider, using the `AWS_ACCOUNT_ID` fetched previously from the `TRUSTED_IDENTITY`
   - For pool, ID must be 'sysdigcloud'
   - Provider must be AWS:
     - Provider name: "Sysdig Secure for Cloud"
     - Attribute mapping, set both `"google.subject" : "assertion.arn"` and `"attribute.aws_role" : "assertion.arn"`

   - Set Pool Binding the role `roles/iam.workloadIdentityUser` with the member value 
     > principalSet://iam.googleapis.com/projects/<GOOGLE_PROJECT_NUMBER>/locations/global/workloadIdentityPools/<IDENTITY_POOL_ID>/attribute.aws_role/arn:aws:sts::<AWS_ACCOUNT_ID>:assumed-role/<AWS_ROLE_NAME>/<AWS_EXTERNAL_ID>"`
      - GOOGLE_PROJECT_NUMBER Google Cloud -> Project number_
      - IDENTITY_POOL_ID _Identity from the pool created in the previous step_
      - AWS_ACCOUNT_ID, AWS_ROLE_NAME, AWS_EXTERNAL_ID


## Confirm services are working

- [Official Docs Check Guide](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-gcp/#confirm-the-services-are-working) 