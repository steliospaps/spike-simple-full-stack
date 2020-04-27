variable "rest_api_id" {
  description = "the id of the rest root object. E.g aws_api_gateway_rest_api.api-gw.id"
  type=string
}

variable "parent_id" {
  description = "the id of the rest parent object. E.g aws_api_gateway_rest_api.api-gw.root_resource_id"
  type=string
}

variable "region" {
  description = "E.g eu-west-1"
  type=string
}

variable "bucket_path" {
  description = "bucket name and path not ending in '/' ('/' will be appended) e.g mybucket/path/to/website/content"
  type=string
}

variable "logging_level" {
  description = "logging level for apigw INFO,WARN?,ERROR"
  default = "ERROR"
  type=string
}

variable "tags" {
  type=map(string)
  default = {}
}
