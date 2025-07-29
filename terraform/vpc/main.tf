resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.name}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "private" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-private-${var.name}-${count.index}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw-${var.name}"
  }
}

resource "aws_eip" "nat" {
  count = var.az_count
  vpc   = true
}

resource "aws_nat_gateway" "this" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.private[count.index].id # can be later changed to public subnet
  depends_on    = [aws_internet_gateway.this]

  tags = {
    Name = "nat-${var.name}-${count.index}"
  }
}
