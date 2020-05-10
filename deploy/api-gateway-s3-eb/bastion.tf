data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["amazon"]


  filter {
    name   = "name"
    values = ["*amzn-ami-hvm-2018.03.0.20190514-x86_64-ebs*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1:0
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3a.nano"
  subnet_id = local.public_subnets[0].id
  vpc_security_group_ids = aws_security_group.bastion-sg.*.id
  associate_public_ip_address = true
  key_name = var.key_name

  tags = merge(
    local.common_tags,
    {
      "Name" = "bastion"
    }
  )
}

resource "aws_security_group" "bastion-sg" {
  count = var.enable_bastion ? 1:0
  name   = "bastion-security-group"
  vpc_id = local.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "bastion_public_ip" {
  value = var.enable_bastion ? aws_instance.bastion[0].public_ip : "BASTION_NOT_CREATED"
}

output "bastion_tunnel_command" {
  value = var.enable_bastion==false ? "" : <<EOF
function aws_connect {
  KEY=$${1?}
  IP=$${2?}
  ssh -i $KEY -o "proxycommand ssh -W %h:%p -i $KEY ec2-user@${aws_instance.bastion[0].public_ip}" ec2-user@$IP
}
EOF
}
