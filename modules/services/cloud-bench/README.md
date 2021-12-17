<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.67.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 3.67.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_task"></a> [task](#module\_task) | ./task | n/a |
| <a name="module_trust_relationship"></a> [trust\_relationship](#module\_trust\_relationship) | ./trust_relationship | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_organizational"></a> [is\_organizational](#input\_is\_organizational) | Whether this task is being created at the org or project level | `bool` | `false` | no |
| <a name="input_organization_domain"></a> [organization\_domain](#input\_organization\_domain) | Organization domain. e.g. sysdig.com | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of project to run the benchmark on | `string` | `""` | no |
| <a name="input_project_ids"></a> [project\_ids](#input\_project\_ids) | IDs of projects to run the benchmark on. If empty, all organization projects will be defaulted. | `list(string)` | `[]` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all regions by default. | `list(string)` | `[]` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the Service Account that will be created. | `string` | `"sysdigcloudbench"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
