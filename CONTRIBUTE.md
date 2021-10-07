# General

- Use **conventional commits** | https://www.conventionalcommits.org/en/v1.0.0
  - Current suggested **scopes** to be used within feat(scope), fix(scope), ...
    - threat
    - bench
    - scan
    - docs
- Maintain example **diagrams** for a better understanding of the architecture and sysdig secure resources
  - example diagram-as-code | https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account/diagram-single.py
  - resulting diagram | https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account/diagram-single.png
- Utilities
  - Useful Terraform development guides | https://www.terraform-best-practices.com



# Pull Request

##Lint
Terraform **lint** and **validation is enforced vía pre-commit** |  https://pre-commit.com
  - custom configuration | https://github.com/sysdiglabs/terraform-google-secure-for-cloud/blob/master/.pre-commit-config.yaml
  - current `terraform-docs` requires developer to create `README.md` file, with the enclosure tags for docs to insert the automated content
  ```markdown
  <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
  ```

## Integration tests
Integration tests are enforced via pre-commit | https://pre-commit.com
Tests configuration can be found in _.github/workflows/ci-integration-test.yaml_. In each PR an action will run this integration tests to check if the modules works properly.

Under **test/fixtures** you can find the targets that will be tested. Please keep this as similar as possible to the Terraform Registry Modules examples.

Kitchen is used to perform this tests which are intended to prove the snippets so that the customer has a working example.
Kitchen configuration can be found in _.kitchen.yml_


### Terraform Backend
The modules _(test/fixtures)_ that are tested with Kitchen use **Terraform backend** to save the _state file_.
The state is stored in a s3 bucket in draios-demo called **kitchen-terraform**.
In order to be able to use this bucket aws credentials should be configured locally for this account.

### CI/CD secrets (WIP)
Currently, the action is configured to use de gcloud SDK.
Some secrets need to be set in the repo, please check _.github/workflows/ci-integration-test.yaml_.

### Deployed resources
We are running this tests in a personal account until we get access to **draios** GCP projects.

### Running the tests locally
Ruby 2.7 is required to launch the tests.
Run `bundle install` to get kitchen-terraform bundle.
GCP project and AWS credentials should be configured locally.
- `bundle exec kitchen converge` will launch the tests, in other words, it will run `terraform apply`
- `bundle exec kitchen destroy` will destroy test infrastructure, in short, it will run `terraform destroy`
- `bundle exec kitchen tests` will run all the workflow. In first place, it will run an `apply`. Then, if and only if the `apply` works it will destroy the infrastructure.




# Release

- Use **semver** for releases https://semver.org
- Module official releases will be published at terraform registry
- Just create a tag/release and it will be  fetched by pre-configured webhook and published into.
  - For internal usage, TAGs can be used
  - For officual verions, RELEASEs will be used, with its corresponding changelog description.
