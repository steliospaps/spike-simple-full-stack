provider "aws" {
  region="eu-west-1"
}

terraform {
  required_version = ">= 0.12.8"
  required_providers {
    aws=">= 2.57.0"
  }
}
