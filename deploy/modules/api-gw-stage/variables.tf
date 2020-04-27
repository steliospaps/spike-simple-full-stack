variable "rest_api_id" {
  description = "the id of the rest root object. E.g aws_api_gateway_rest_api.api-gw.id"
  type=string
}

variable "stage_dependencies" {
  description = "dependencies so that the stage is created only after everything else"
  default = []
}

variable "stage_name" {
  description = "the stage name of the deployment. e.g. test"
  type=string
}

variable "tags" {
  type=map(string)
  default = {}
}
