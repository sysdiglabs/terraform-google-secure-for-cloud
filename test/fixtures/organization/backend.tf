# Terraform state storage backend
terraform {
  backend "s3" {
    bucket         = "kitchentest-terraform"
    key            = "gcp-org/terraform.tfstate"
    dynamodb_table = "gcp_org_kitchen_test"
    region         = "eu-west-3"
  }
}
