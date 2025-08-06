provider "aws" {
  region = "us-west-1"
}

module "vpc_gateway" {
  source         = "../../modules/vpc"
  project_prefix = "gateway"
  vpc_cidr       = "10.10.0.0/16"
  azs            = ["us-west-1a"] # ← only one AZ
  enable_nat     = true
}

# ALSO add the backend VPC module here to reference both
module "vpc_backend" {
  source         = "../../modules/vpc"
  project_prefix = "backend"
  vpc_cidr       = "10.20.0.0/16"
  azs            = ["us-west-1a"]
  enable_nat     = true
}

resource "aws_vpc_peering_connection" "gw_to_backend" {
  vpc_id        = module.vpc_gateway.vpc_id
  peer_vpc_id   = module.vpc_backend.vpc_id
  auto_accept   = true

  tags = {
    Name = "gateway-backend-peering"
  }
}

# Route from Gateway to Backend
resource "aws_route" "to_backend" {
  route_table_id            = module.vpc_gateway.private_route_table_id
  destination_cidr_block    = "10.20.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.gw_to_backend.id
}

# Route from Backend to Gateway
resource "aws_route" "to_gateway" {
  route_table_id            = module.vpc_backend.private_route_table_id
  destination_cidr_block    = "10.10.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.gw_to_backend.id
}

output "vpc_peering_id" {
  value = aws_vpc_peering_connection.gw_to_backend.id
}

output "gateway_vpc_id" {
  value = module.vpc_gateway.vpc_id
}
