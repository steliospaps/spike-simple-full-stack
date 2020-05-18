
resource "aws_security_group" "eb_ec2" {
  name_prefix   = "eb_ec2-security-group"
  vpc_id = local.vpc.id
  tags = local.common_tags

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = list(aws_security_group.eb_lb.id)
  }
  //TODO: make it talk only to the vpc endpoints
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eb_lb" {
  name_prefix   = "eb_loadbalancer-security-group"
  vpc_id = local.vpc.id
  tags = local.common_tags

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eb_vpc_endpoint" {
  name_prefix   = "eb_vpc-endpoint-security-group"
  vpc_id = local.vpc.id
  tags = local.common_tags

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.private_subnets.*.cidr_block
  }
}

#### endpoints needed by elb

resource "aws_vpc_endpoint" "sqs" {
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${var.region}.sqs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]
  subnet_ids = local.private_subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}

resource "aws_vpc_endpoint" "cloudformation" {
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${var.region}.cloudformation"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]
  subnet_ids = local.private_subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}


resource "aws_vpc_endpoint" "eb" {
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${var.region}.elasticbeanstalk"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]
  subnet_ids = local.private_subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}

resource "aws_vpc_endpoint" "eb_health" {
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${var.region}.elasticbeanstalk-health"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]

  subnet_ids = local.private_subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = local.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [ local.vpc.main_route_table_id ]
  tags = local.common_tags
}
