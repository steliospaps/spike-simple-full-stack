variable "region" {
  description = "the region (where this is applied)"
}

variable "STATE_BUCKET" {
 //comes from env TF_VAR_STATE_BUCKET
  description = "the state bucket."
}
variable "STATE_REGION" {
//comes from env TF_VAR_STATE_REGION
  description = "the state region"
}

variable "key" {
//comes from backend.auto.tfvars
  description = "the key inside the state bucket"
}

variable "billing_tag" {
  type=string
  default="STELIOS"
}

variable "key_name" {
  type=string
  description = "key for the bastion host and the ec2boxes"
}

locals {
  common_tags = {
    "billing"="${var.billing_tag}",
    "Terraform"="${var.STATE_REGION}:${var.STATE_BUCKET}:${var.key}"
  }
}
