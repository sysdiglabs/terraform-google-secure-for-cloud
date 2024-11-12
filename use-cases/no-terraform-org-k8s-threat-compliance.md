# Organizational - Kubernetes only (no TF) - Threat Detection and Compliance

## Use-Case explanation

- Organizational setup
  - Dynamic environments with projects created and destroyed on-demand
- Sysdig features: Threat-detection for all org accounts. No image scanning
- Due to dynamic nature of customer's environment, a heavy programmatically ops tooling are used (not including Terraform) .
- A summary of the required resources/permissions will be done, so they're provisioned for the Secure for Cloud feature sto work.

## Infrastructure Solution

As a quick summary we'll need

- Organization
  - Log Router Sink
- Member project (Sysdig resources, existing project or new one)
  - PubSub to wire events from the log router into cloud-connector compute module
  - K8s cluster for cloud-connector (Sysdig compute workload for threat detection)

![overall infrastructure](resources/diagram-org-k8s-threat-compliance.png)

<br/><br/>

### Cloud-Connector wiring: Log Router Sink + PubSub Topic

0. From your organization, **choose a member project** as `SYSDIG_PROJECT_ID`
1. In `SYSDIG_PROJECT_ID`, create a **Pub/Sub** topic (with default configuration is enough)
   - Save `SYSDIG_PUBSUB_SUBSCRIPTION_NAME` for later
2. In the organizational domain level, create **Logging Logs Router** Sink
   - Add as destination the Pub/Sub from previous point.
   - Choose to ingest organization and child resources
   - Set the following filter
    ```text
    logName=~"/logs/cloudaudit.googleapis.com%2Factivity$" AND -resource.type="k8s_cluster"
    ```
3. Give Sink **Permissions** to write on PubSub
   - Grab the `Writer Identity` user from the just created Sink
   - In the PubSub resource, grant `Pub/Sub Publisher` role to the Sink `Writer Identity`

<br/><br/>
### Secure for Cloud Compute Deployment

<!--
-- TODO. authentication howto.
- 1/first approach would be to create a SA

small explanation here https://github.com/sysdiglabs/terraform-google-secure-for-cloud/tree/master/examples/single-project-k8s
and code reference here https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/examples/single-project-k8s/cloud-connector-config.tf#L21

- 2/more elegant approach to use the serviceAccount from the chart. talk with @javi
-->

1. Credentials Creation
   - This step is not really required if Kubernetes role binding is properly binded with a cloud IAM role with required permissions bellow.
   - Create Service Account with the `pubsub/subscriber` role.
   - Get the JSON credentials file for the created Service Account `<JSON_CONTENT_FROM_THE_CREDENTIALS_FILE>` (this would be an example of the content).
       ```
         {
           "type": "service_account",
           "project_id": ...
           "private_key_id": ...
           ...
         }
       ```
<br/>

2. Sysdig **Helm** [cloud-connector chart](https://charts.sysdig.com/charts/cloud-connector/) will be used with following parametrization
   - Locate your `<SYSDIG_SECURE_ENDPOINT>` and `<SYSDIG_SECURE_API_TOKEN>`. [Howto fetch ApiToken](https://docs.sysdig.com/en/docs/administration/administration-settings/user-profile-and-password/retrieve-the-sysdig-api-token/)


```yaml
rules: []
scanners: []
sysdig:
  url: <SYSDIG_SECURE_ENDPOINT>
  secureAPIToken: <SYSDIG_SECURE_API_TOKEN>

# not required but would help product
telemetryDeploymentMethod: "helm_gcp_k8s_org"

ingestors:
  # receives GCP auditlog from a PubSub topic
  - gcp-auditlog-pubsub:
      project: <SYSDIG_PROJECT_ID>
      subscription: <SYSDIG_PUBSUB_SUBSCRIPTION_NAME>

gcpCredentials: |
  <JSON_CONTENT_FROM_THE_CREDENTIALS_FILE> (beware of the tabulation)
```

Check that deployment logs throw no errors and can go to [confirm services are working](#confirm-services-are-working) for threat detection functionality checkup.
<br/>
<br/>

## Confirm services are working

- [Forcing events](https://github.com/sysdiglabs/terraform-google-secure-for-cloud#forcing-events)
