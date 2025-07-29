terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3"
}

provider "aws" {
  region = var.aws_region
}

module "vpc_gateway" {
  source       = "./terraform/vpc"
  name         = "gateway"
  cidr_block   = "10.10.0.0/16"
  az_count     = 2
}

module "vpc_backend" {
  source       = "./terraform/vpc"
  name         = "backend"
  cidr_block   = "10.20.0.0/16"
  az_count     = 2
}
