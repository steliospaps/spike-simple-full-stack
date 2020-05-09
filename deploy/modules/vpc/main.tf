
locals{
  vpc = aws_vpc.default
  // alternative values aws_vpc.main.id
  common_tags = var.tags
  zone_count = var.zone_count > 0 ? min(var.zone_count,length(data.aws_availability_zones.available.names)) : length(data.aws_availability_zones.available.names)
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block = var.cidr
  enable_dns_hostnames = true
  tags = merge(
    local.common_tags,
    {
      "Name" = "myVpc"
    }
  )
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id
  tags = merge(
    local.common_tags,
    {
      "Name" = "myVpc-gw"
    }
  )
}

resource "aws_subnet" "public" {
  count = local.zone_count
  vpc_id = local.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block= cidrsubnet(local.vpc.cidr_block, 8, count.index*2+1)
  map_public_ip_on_launch = true
  tags = merge(
    local.common_tags,
    {
      "Name" = "public-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count = local.zone_count
  vpc_id = local.vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block= cidrsubnet(local.vpc.cidr_block, 8, count.index*2+2)
  map_public_ip_on_launch = false
  tags = merge(
    local.common_tags,
    {
      "Name" = "private-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}
