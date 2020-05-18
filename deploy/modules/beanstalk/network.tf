
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
