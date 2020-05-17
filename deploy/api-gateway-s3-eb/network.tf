module "vpc" {
  source = "../modules/vpc"
  zone_count = 2
  cidr="10.1.0.0/16"
  tags = local.common_tags
  enable_flow_log=false
}

locals{
  vpc = module.vpc.vpc
  // alternative values aws_vpc.main.id

  public_subnets=module.vpc.public_subnets
  private_subnets=module.vpc.private_subnets
}
