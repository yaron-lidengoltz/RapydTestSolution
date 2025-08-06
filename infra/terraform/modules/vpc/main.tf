resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_prefix}-vpc"
  }
}

resource "aws_subnet" "private" {
  count                   = 1
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_prefix}-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  count  = var.enable_nat ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_prefix}-igw"
  }
}

resource "aws_eip" "nat" {
  count = var.enable_nat ? 1 : 0

  tags = {
    Name = "${var.project_prefix}-eip"
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.private[0].id
  depends_on    = [aws_internet_gateway.this]

  tags = {
    Name = "${var.project_prefix}-natgw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_prefix}-private-rt"
  }
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  count          = 1
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
