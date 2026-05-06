terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    vault = {
      source  = "hashicorp/vault"
  }
}
}

provider "aws" {
  region = var.aws_region
}
