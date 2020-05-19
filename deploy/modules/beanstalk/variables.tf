locals{
  vpc_id = var.vpc_id
  // alternative values aws_vpc.main.id
  public_subnets=var.loadbalancer_subnet_ids
  private_subnets=var.instance_subnet_ids
  common_tags=var.tags
}

variable vpc_id {
  type=string
}

variable instance_subnet_ids {
  type=list(string)
}

variable loadbalancer_subnet_ids {
  type=list(string)
}

variable tags {

}

variable app_name {
  type=string
}
variable env_name {
  type=string
}

variable dummy_app_location {
  default=""
}

variable key_name {
  default=""
}

variable config_override {
  default ={"dummy_ns_so_that_type_is_correct"={"key"="value"}}
  description=" a map of namespace => name=>value see https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/beanstalk-environment-configuration-advanced.html and https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html"
}

/*
    Add the following line to the resource in this module that depends on the completion of external module components:

    depends_on = [null_resource.module_depends_on]

    This will force Terraform to wait until the dependant external resources are created before proceeding with the creation of the
    resource that contains the line above.

    This is a hack until Terraform officially support module depends_on.
*/

variable "module_depends_on" {
  default = [""]
}

resource "null_resource" "module_depends_on" {
  triggers = {
    value = "${length(var.module_depends_on)}"
  }
}
