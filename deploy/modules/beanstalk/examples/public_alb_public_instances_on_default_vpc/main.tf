provider "aws" {
  region="eu-west-1"
}

resource "aws_default_vpc" "default" {
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_subnet" "default" {
  count = length(data.aws_availability_zones.available.names.*)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

module "eb" {
  source = "../../"
  vpc_id = null
  loadbalancer_subnet_ids=aws_default_subnet.default.*.id
  instance_subnet_ids=aws_default_subnet.default.*.id
  tags = {
    "Terraform"=true
  }

  app_name=local.app_name
  env_name=local.env_name

  config_override={
    "aws:ec2:vpc" = {
      "AssociatePublicIpAddress" = true
    }
  }
}


locals{
  app_name="my-test-app"
  env_name="my-test-env"
}

output "backend_url" {
  value = module.eb.endpoint_url
}
output "backend_eb_app" {
  value = local.app_name
}
output "backend_eb_env" {
  value = local.env_name
}
output "backend_eb_bucket" {
  value = module.eb.bucket
}
