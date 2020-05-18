resource "aws_security_group" "eb_vpc_endpoint" {
  name_prefix   = "eb_vpc-endpoint-security-group"
  vpc_id = local.vpc.id
  tags = local.common_tags

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = local.private_subnets.*.cidr_block
  }
}

data "aws_region" "current" {}


#### endpoints needed by elb

resource "aws_vpc_endpoint" "sqs" {
  count=var.enable_beanstalk_endpoints ? 1 : 0
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.sqs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]
  subnet_ids = local.private_subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}

resource "aws_vpc_endpoint" "cloudformation" {
  count=var.enable_beanstalk_endpoints ? 1 : 0
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.cloudformation"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]
  subnet_ids = local.private_subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}


resource "aws_vpc_endpoint" "eb" {
  count=var.enable_beanstalk_endpoints ? 1 : 0
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.elasticbeanstalk"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]
  subnet_ids = local.private_subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}

resource "aws_vpc_endpoint" "eb_health" {
  count=var.enable_beanstalk_endpoints ? 1 : 0
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.elasticbeanstalk-health"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]

  subnet_ids = local.private_subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}

resource "aws_vpc_endpoint" "s3" {
  count=var.enable_beanstalk_endpoints ? 1 : 0
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ local.vpc.main_route_table_id ]
  tags = local.common_tags
}
