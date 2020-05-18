locals{
  vpc = var.vpc
  // alternative values aws_vpc.main.id
  public_subnets=var.public_subnets
  private_subnets=var.private_subnets
  common_tags=var.tags
}

variable vpc {

}

variable private_subnets {

}

variable public_subnets {

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
  default ={}
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
