# Cloud Bench deploy for GCP

Deployed on the **target GCP account(s)**:
- The required Workload Identity Pool + Provider + Service Account,  to allow Sysdig to run GCP Benchmarks on your behalf.

Deployed on **Sysdig Backend**
- An `gcp_foundations_bench-1.2.0` benchmark task schedule on a random hour of the day `rand rand * * *`
- coped to the configured `gcp.projectId` and `gcp.region`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.21.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.21.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_trust_relationship"></a> [trust\_relationship](#module\_trust\_relationship) | ./trust_relationship | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational) | Whether this task is being created at the org or project level | `bool` | `false` | no |
| <a name="input_organization_domain"></a> [organization\_domain](#input\_organization\_domain) | Organization domain. e.g. sysdig.com | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Google cloud project ID to run Benchmarks on. It will create a trust-relationship, to allow Sysdig usage. | `string` | `""` | no |
| <a name="input_project_ids"></a> [project\_ids](#input\_project\_ids) | Google cloud project IDs to run Benchmarks on. It will create a trust-relationship on each, to allow Sysdig usage. If empty, all organization projects will be defaulted. | `list(string)` | `[]` | no |
| <a name="input_reuse_workload_identity_pool"></a> [reuse\_workload\_identity\_pool](#input\_reuse\_workload\_identity\_pool) | Reuse existing workload identity pool, from previous deployment, with name 'sysdigcloud'. <br/> Will help overcome <a href='https://github.com/sysdiglabs/terraform-google-secure-for-cloud#q-getting-error-creating-workloadidentitypool-googleapi-error-409-requested-entity-already-exists'>redeploying error due to GCP softdelete</a><br/> | `bool` | `false` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the Service Account/Role that will be created. Modify this value in case of conflict / 409 error to bypass Google soft delete | `string` | `"sysdigcloudbench"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
