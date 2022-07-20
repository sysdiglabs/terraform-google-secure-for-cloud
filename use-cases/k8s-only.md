# k8s only

## Use-Case explanation

### Requirements

- Organizational setup
  - Dinamic environments
- Sysdig feats: Threat-detection, Compliance
- Customer provides all ops related tools (which don't include Terraform), so all Terraform provided stuff must be documented

## Solution

### Infra

![](TO-BE-DONE-K8S-ONLY.png)

TODO: This diagram must be _pythonized_

#### Requirements

##### CC PubSub Topic + Log Router Sink (Threat)

Create a topic

Create Sink at organizational domain:
- Add as destination the pubsub
- Choose to ingest organization and child resources
- Set the following filter `logName=~"/logs/cloudaudit.googleapis.com%2Factivity$" AND -resource.type="k8s_cluster"`

Give the `Writer Identity` user from the sink `Pub/Sub Publisher` role.

##### cajita k8s/CloudConnector(Threat) (to be hidden)

User should provide a k8s cluster to install CloudConnector on it. Both self installed and GKE are valid.

##### Cloud Bench Role (Compliance)

For

### How to deploy Cloud Connector



#### Cloud connector helm setup parms

`gcpCredentials`
`sysdig.url`
`sysdig.secureAPIToken`
`ingestors`
  - gcp-gcr-pubsub: # Receives GCP GCR from a PubSub topic
      project:
      subscription:

### How to enable a rol for Compliance
