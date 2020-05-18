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

variable "use_public_ips" {
  type=bool
  default = true
  description = "use public ips for the instances. This alloes them to talk to the internet"
}

locals {
  common_tags = {
    "billing"="${var.billing_tag}",
    "Terraform"="${var.STATE_REGION}:${var.STATE_BUCKET}:${var.key}"
  }
}
