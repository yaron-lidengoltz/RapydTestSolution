variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
}
