# RapydTestSolution

# Sentinel Split Architecture – DevSecOps Technical Challenge

This project is a proof-of-concept environment for Rapyd Sentinel's split architecture. It demonstrates secure and modular infrastructure using Terraform, EKS, and GitHub Actions for CI/CD.

## Architecture Overview

The system consists of two isolated environments:

- **Gateway Layer (Public)** – Exposes a reverse proxy with public access
- **Backend Layer (Private)** – Hosts internal processing services

Each environment:
- Runs in a separate AWS VPC
- Has its own EKS Kubernetes cluster
- Communicates privately via VPC peering (or Transit Gateway)

---

Part 1: Cloud Infrastructure (Terraform)
Goal: Build an isolated dual-VPC setup with EKS clusters.

Tasks:
  1. Create two AWS VPCs:
     - vpc-gateway – for the public-facing proxy
     - vpc-backend – for the internal backend service

  2. Each VPC must include:
     - Two private subnets in different Availability Zones
     - NAT Gateway (if outbound internet access is needed)
     - No public EC2s or wide-open access rules

  3. Private Networking Between VPCs:
     - Use VPC Peering (or Transit Gateway as an alternative)
     - Set up routing tables and security groups to allow secure traffic between VPCs

  4. EKS Cluster Setup:
     - Deploy one EKS cluster per VPC:
       - eks-gateway in vpc-gateway
       - eks-backend in vpc-backend

Use Terraform modules for clean, reusable infrastructure-as-code



Part 2: Kubernetes Workloads
Goal: Deploy an internal backend service and a public proxy, with private communication between them.

Tasks:
  1. On eks-backend:
     - Deploy a simple internal backend service (e.g., returns "Hello from backend")
     - Do not expose it to the internet

  2. On eks-gateway:
     - Deploy a proxy application (e.g., NGINX or Node.js forwarder)
     - Expose it via a public LoadBalancer
     - Route all incoming traffic to the internal backend over the VPC connection

  3. Networking Configuration:
     - Use DNS or hardcoded internal IPs
     - Set Security Groups to allow traffic to backend only from the gateway cluster
     - Optionally: Add NetworkPolicies to restrict pod-to-pod access in the backend cluster

Part 3: CI/CD Pipeline (GitHub Actions)
Goal: Automate the infrastructure and deployment process.

Tasks:
  1. Trigger: On every push to the repository
  2. Steps:
     - Run terraform validate, tflint
     - Run terraform plan and terraform apply
     - Run kubeval and kubectl apply --dry-run
     - Deploy the backend and proxy apps

  3. Optional Bonus:
     - Use GitHub OIDC Federation to deploy to AWS without storing long-lived credentials



Part 4: Documentation (README.md)
Goal: Provide clear, professional documentation of your design and decisions.

Include:
  - How to clone and run the project
  - How networking is configured between the VPCs and clusters
  - How the proxy communicates with the backend
  - Security explanation: Security Groups and optional NetworkPolicy
  - CI/CD pipeline overview
  - Any trade-offs due to the 3-day time limit
  - Optional: Cost optimization notes (e.g., instance types, NAT usage)
  - What you would build next (TLS/mTLS, observability, GitOps, service mesh, Vault, etc.)



Part 5: Validation & Testing
Goal: Confirm everything is working as expected.

Tests to Run:
  - Proxy is able to reach the backend
  - Backend is not accessible from the internet
  - Terraform plan and apply work without errors
  - Kubernetes manifests are valid
  - CI/CD pipeline runs successfully