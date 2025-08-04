provider "aws" {
  region = "eu-west-1"  # You can change this to your desired region
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
