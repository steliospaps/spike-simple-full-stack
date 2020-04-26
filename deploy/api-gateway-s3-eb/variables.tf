variable "region" {
  description = "the region (where this is applied)"
}

variable "STATE_BUCKET" {
  description = "the state bucket"
}
variable "STATE_REGION" {
  description = "the state region"
}

variable "key" {
  description = "the key inside the state bucket"
}

variable "billing_tag" {
  type=string
  default="STELIOS"
}

locals {
  common_tags = {
    "billing"="${var.billing_tag}",
    "Terraform"="${var.STATE_REGION}/${var.STATE_BUCKET}/${var.key}"
  }
}
