provider "aws" {
  region="eu-west-1"
}

module "vpc" {
  source = "../../"
  zone_count = 1
  cidr="10.1.0.0/16"
  tags = {
    "Terraform"=true
  }
}
