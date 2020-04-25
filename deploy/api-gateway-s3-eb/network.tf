
locals{
  vpc = aws_default_vpc.default
  // alternative values aws_vpc.main.id

  subnets=aws_default_subnet.subnets
}

resource "aws_default_vpc" "default" {
}

resource "aws_default_subnet" "subnets" {
  count = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]

}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "eb_ec2" {
  name_prefix   = "eb_ec2-security-group"
  vpc_id = local.vpc.id
  tags = merge(
    local.common_tags
  )

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = list(aws_security_group.eb_lb.id)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "eb_lb" {
  name_prefix   = "eb_loadbalancer-security-group"
  vpc_id = local.vpc.id
  tags = merge(
    local.common_tags
  )

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
