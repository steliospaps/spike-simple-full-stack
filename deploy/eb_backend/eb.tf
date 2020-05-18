module "eb" {
  source = "../modules/beanstalk"
  vpc = local.vpc
  public_subnets=local.public_subnets
  private_subnets=local.private_subnets
  tags =  local.common_tags
  dummy_app_location = "dummy_backend/target/beanstalk.zip"
  module_depends_on = [null_resource.dummy_backend]

  app_name=local.app_name
  env_name=local.env_name

  config_override={
     "aws:elasticbeanstalk:application:environment" = {
        "SERVER_PORT" = "5000"
        "CORS_ALLOWED_ORIGINS"="${local.frontend_base_url}"
        "CORS_ALLOWED_METHODS"="GET,POST"
    }
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
