output "private_subnets" {
  description = "private subnets type = aws_subnet"
  value = local.private_subnets
}

output "public_subnets" {
  description = "public subnets type = aws_subnet"
  value = local.public_subnets
}

output "vpc" {
  description="the created vpc"
  value = local.vpc
}
