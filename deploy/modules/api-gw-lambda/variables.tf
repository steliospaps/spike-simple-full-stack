variable "rest_api_id" {
  description = "the id of the rest root object. E.g aws_api_gateway_rest_api.api-gw.id"
  type=string
}

variable "parent_id" {
  description = "the id of the rest parent object. E.g aws_api_gateway_rest_api.api-gw.root_resource_id"
  type=string
}

variable "lambda_invoke_arn" {
  description = "lambda invoke arn to tunnel call"
  type=string
}

variable override_options {
  default = true
  description = "override options"
}

variable options_allow_headers {
  default = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
}

variable options_allow_methods {
  default = "'GET,OPTIONS,POST,PUT'"
}

variable options_allow_origin {
  default = "'*'"
}

variable "methods" {
  description = "methods to send to lambda, add OPTIONS here and set override_options to false to handle that in the lambda"
  type=list(string)
  default=["GET","POST","PUT"]
}

variable "path_part" {
  description = "path of the endpoint empty string means root"
  type=string
  default=""
}

variable "tags" {
  type=map(string)
  default = {}
}
