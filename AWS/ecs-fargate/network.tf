resource "aws_vpc" "cloudbeaver_net" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(var.common_tags, { Name = "Cloudbeaver network" })
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnets" {
  depends_on = [aws_vpc.cloudbeaver_net]

  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.cloudbeaver_net.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, { Name = "Cloudbeaver Public Subnet ${count.index + 1}" })

}

resource "aws_subnet" "private_subnets" {
  depends_on = [aws_vpc.cloudbeaver_net]

  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.cloudbeaver_net.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, { Name = "Cloudbeaver Private Subnet ${count.index + 1}" })

  
}

resource "aws_internet_gateway" "cloudbeaver_gw" {
  vpc_id = aws_vpc.cloudbeaver_net.id
  depends_on = [aws_vpc.cloudbeaver_net]

  tags = merge(var.common_tags, { Name = "Cloudbeaver VPC IG" })
}


resource "aws_route" "cloudbeaver_vpc_main_gw" {
  depends_on = [
    aws_vpc.cloudbeaver_net,
    aws_internet_gateway.cloudbeaver_gw
  ]

  route_table_id = aws_vpc.cloudbeaver_net.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.cloudbeaver_gw.id

}


resource "aws_eip" "cloudbeaver_nat_gateway" {
  domain           = "vpc"

  tags = merge(var.common_tags, { Name = "Cloudbeaver EIP for Private VPC" })
}


resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [
    aws_vpc.cloudbeaver_net,
    aws_subnet.public_subnets
  
  ]
  allocation_id = aws_eip.cloudbeaver_nat_gateway.id
  subnet_id = aws_subnet.public_subnets[0].id

  tags = merge(var.common_tags, { Name = "Cloudbeaver Private Subnets Nat Gateway" })
}

resource "aws_route_table" "cloudbeaver_private_rt_nat" {
  depends_on = [
    aws_vpc.cloudbeaver_net,
    aws_eip.cloudbeaver_nat_gateway
  ]

  vpc_id = aws_vpc.cloudbeaver_net.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(var.common_tags, { Name = "Cloudbeaver Private Route Table" })
}

resource "aws_route_table_association" "private_subnets_rt" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.cloudbeaver_private_rt_nat.id
}