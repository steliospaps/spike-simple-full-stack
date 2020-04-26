variable "zone_count" {
  description = "maximum zones this vpc will span over <=0 means all"
  default = 0
  type = number
}

variable "cidr" {
  description = "cidr of the vpc"
  default = "10.0.0.0/16"
  type=string
}

variable "tags" {
  description = "tags"
  type = map(string)
  default = {
    "Terraform" = "true"
  }
}
