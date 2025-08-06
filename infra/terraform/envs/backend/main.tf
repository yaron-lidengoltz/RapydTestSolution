provider "aws" {
  region = "us-west-1"
}

module "vpc_backend" {
  source         = "../../modules/vpc"
  project_prefix = "backend"
  vpc_cidr       = "10.20.0.0/16"
  azs            = ["us-west-1a"]
  enable_nat     = true
}

output "backend_vpc_id" {
  value = module.vpc_backend.vpc_id
}
