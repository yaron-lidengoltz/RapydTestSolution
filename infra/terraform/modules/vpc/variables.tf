variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "project_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "enable_nat" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = true
}
