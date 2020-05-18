variable "rest_api_id" {
  description = "the id of the rest root object. E.g aws_api_gateway_rest_api.api-gw.id"
  type=string
}

variable "parent_id" {
  description = "the id of the rest parent object. E.g aws_api_gateway_rest_api.api-gw.root_resource_id"
  type=string
}

variable "url" {
  description = "url to tunnel to"
  type=string
}

variable "path_part" {
  description = "path of the endpoint"
  type=string
  default=""
}

variable "tags" {
  type=map(string)
  default = {}
}
