
locals{
  vpc = aws_vpc.default
  // alternative values aws_vpc.main.id
  common_tags = var.tags
  public_subnets=aws_subnet.public
  private_subnets=aws_subnet.private
  zone_count = var.zone_count > 0 ? min(var.zone_count,length(data.aws_availability_zones.available.names)) : length(data.aws_availability_zones.available.names)
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block = var.cidr
  enable_dns_hostnames = true
  tags = local.common_tags
}

resource "aws_subnet" "public" {
  count = local.zone_count
  vpc_id = local.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block= cidrsubnet(local.vpc.cidr_block, 8, count.index*2+1)
  map_public_ip_on_launch = true
  tags = local.common_tags
}

resource "aws_subnet" "private" {
  count = local.zone_count
  vpc_id = local.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block= cidrsubnet(local.vpc.cidr_block, 8, count.index*2+2)
  map_public_ip_on_launch = false
  tags = local.common_tags
}

/*
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
  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
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
    security_groups = [aws_security_group.eb_ec2.id]
  }
  //TODO: is egress needed?
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_vpc_endpoint" "eb" {
  vpc_id            = local.vpc.id
  //TODO: variable for region
  service_name      = "com.amazonaws.eu-west-1.elasticbeanstalk"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]
  subnet_ids = local.subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}

resource "aws_vpc_endpoint" "eb_health" {
  vpc_id            = local.vpc.id
  //TODO: variable for region
  service_name      = "com.amazonaws.eu-west-1.elasticbeanstalk-health"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.eb_vpc_endpoint.id,
  ]

  subnet_ids = local.subnets.*.id
  private_dns_enabled = true
  tags = local.common_tags
}
*/
