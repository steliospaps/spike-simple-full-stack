output "private_subnets" {
  description = "private subnets type = aws_subnet"
  value = aws_subnet.private
}

output "public_subnets" {
  description = "public subnets type = aws_subnet"
  value = aws_subnet.public
}

output "vpc" {
  description="the created vpc"
  value = local.vpc
}
