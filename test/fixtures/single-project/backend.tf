# Terraform state storage backend
terraform {
  backend "s3" {
    bucket         = "kitchentest-terraform"
    key            = "gcp-single/terraform.tfstate"
    dynamodb_table = "gcp_single_kitchen_test"
    region         = "eu-west-3"
  }
}
