variable "billing_tag" {
  type=string
  default="STELIOS"
}

locals {
  common_tags = {
    "billing"="${var.billing_tag}",
    "Terraform"="true"
  }
}

variable "apply_immediatelly" {
  type=bool
  description = "apply immediatelly even if this would cause a service disruption"
  default = false
}
