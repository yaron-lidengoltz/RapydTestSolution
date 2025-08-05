# PART 0 – Project Bootstrap
- Create project folder structure
    infra/terraform/modules/vpc/
    infra/terraform/modules/eks/
    infra/terraform/envs/gateway/
    infra/terraform/envs/backend/
    infra/scripts/
    .github/workflows/
    README.md


# PART 1 – VPC Setup
## 1.1 Create the reusable VPC module (modules/vpc)
    Create main.tf, outputs.tf, and variables.tf in modules/vpc

- Define the following resources:
    aws_vpc
    2x aws_subnet (in 2 AZs)
    2x aws_route_table and aws_route_table_association
    aws_nat_gateway (optional based on input variable)
    aws_eip (for NAT)

- Add input variables for:
    vpc_cidr, azs, project_prefix, enable_nat
- Add outputs:
    vpc_id, private_subnet_ids, nat_gateway_id

## 1.2 Use the VPC module to create the Gateway VPC
- In envs/gateway/main.tf, use your VPC module:
```
module "gateway_vpc" {
  source        = "../../modules/vpc"
  vpc_cidr      = "10.10.0.0/16"
  azs           = ["eu-west-1a", "eu-west-1b"]
  project_prefix = "gateway"
  enable_nat    = true
}
```

## 1.3 Use the VPC module to create the Backend VPC
- In envs/backend/main.tf, similarly:
```
module "backend_vpc" {
  source        = "../../modules/vpc"
  vpc_cidr      = "10.20.0.0/16"
  azs           = ["eu-west-1a", "eu-west-1b"]
  project_prefix = "backend"
  enable_nat    = true
}
// Use the same module with different CIDRs and prefixes.
```

# PART 2 - VPC Peering
## 2.1 Create VPC Peering connection
- In either envs/gateway or a shared file:
```
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = module.gateway_vpc.vpc_id
  peer_vpc_id   = module.backend_vpc.vpc_id
  auto_accept   = true
  tags = {
    Name = "gateway-backend-peer"
  }
}

```

## 2.2 Add routing between VPCs
- Add aws_route entries to both VPCs’ route tables:
```
resource "aws_route" "gateway_to_backend" {
  route_table_id         = module.gateway_vpc.private_route_table_ids[0]
  destination_cidr_block = "10.20.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
```

## 2.3 Configure Security Groups
- Allow internal traffic between VPCs using security groups
```
resource "aws_security_group_rule" "allow_backend" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = module.backend_eks.node_sg
  cidr_blocks       = ["10.10.0.0/16"]
}
```

# PART 3 - EKS Cluster Setup
## 3.1 Build a reusable EKS module (modules/eks)
- Create a module that provisions:
    aws_eks_cluster
    aws_eks_node_group
    Optionally: IAM roles (use data sources or locals for now)
- Inputs: vpc_id, subnet_ids, cluster_name
- Outputs: cluster_name, kubeconfig, node_group_info

## 3.2 Deploy eks-gateway cluster
- In envs/gateway/main.tf:
```
module "eks_gateway" {
  source      = "../../modules/eks"
  cluster_name = "eks-gateway"
  vpc_id      = module.gateway_vpc.vpc_id
  subnet_ids  = module.gateway_vpc.private_subnet_ids
}
```

## 3.3 Deploy eks-backend cluster
- In envs/backend/main.tf:
```
module "eks_backend" {
  source      = "../../modules/eks"
  cluster_name = "eks-backend"
  vpc_id      = module.backend_vpc.vpc_id
  subnet_ids  = module.backend_vpc.private_subnet_ids
}
```

# PART 4 - GitHub Actions (CI/CD)
## 4.1 Create workflow file
- Create .github/workflows/deploy.yml

## 4.2 Validate and Apply Infrastructure
```
name: Terraform CI

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init
        working-directory: infra/terraform/envs/gateway

      - name: Terraform Validate
        run: terraform validate
        working-directory: infra/terraform/envs/gateway

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: infra/terraform/envs/gateway
```

# PART 5 - (Optional) Extras for Polish
- Add infra/scripts/run_terraform.sh or .bat
- Add remote state config (S3 + DynamoDB locking)
- Document assumptions, usage instructions in README.md
- Export AWS account ID to verify permissions (like you did):
```
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```