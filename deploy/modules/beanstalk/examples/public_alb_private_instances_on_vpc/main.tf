provider "aws" {
  region="eu-west-1"
}

module "vpc" {
  source = "../../../vpc"
  zone_count = 2
  cidr="10.1.0.0/16"
  tags = {}
  enable_flow_log=false
}


module "eb" {
  source = "../../"
  vpc_id = module.vpc.vpc.id
  loadbalancer_subnet_ids=module.vpc.public_subnets.*.id
  instance_subnet_ids=module.vpc.private_subnets.*.id
  tags = {
    "Terraform"=true
  }
  dummy_app_location = "dummy_backend/target/beanstalk.zip"
  module_depends_on = [null_resource.dummy_backend]

  app_name=local.app_name
  env_name=local.env_name

  config_override={

  }
}

resource "null_resource" "dummy_backend" {
  provisioner "local-exec" {
    command = "cd dummy_backend && make build"
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
