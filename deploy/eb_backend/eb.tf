module "eb" {
  source = "../modules/beanstalk"
  vpc_id = local.vpc.id
  loadbalancer_subnet_ids=local.public_subnets.*.id
  instance_subnet_ids=var.use_public_ips ? local.public_subnets.*.id : local.private_subnets.*.id
  tags =  local.common_tags
  dummy_app_location = var.use_public_ips ? "" : "dummy_backend/target/beanstalk.zip"
  module_depends_on = [null_resource.dummy_backend.*]

  app_name=local.app_name
  env_name=local.env_name

  config_override={
    "aws:elasticbeanstalk:application:environment" = {
      "SERVER_PORT" = "5000"
      "CORS_ALLOWED_ORIGINS"="${local.frontend_base_url}"
      "CORS_ALLOWED_METHODS"="GET,POST"
    }
    "aws:ec2:vpc" = {
      "AssociatePublicIpAddress" = var.use_public_ips
    }
  }
}

resource "null_resource" "dummy_backend" {
  count = var.use_public_ips ? 0 : 1
  provisioner "local-exec" {
    command = "cd dummy_backend && make build"
  }
}

locals{
  app_name="my-test-app"
  env_name="my-test-env"
}

output "backend_eb_url" {
  value = "http://${module.eb.cname}"
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
