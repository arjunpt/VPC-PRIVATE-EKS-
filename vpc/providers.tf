terraform {
  required_version = ">= 1.4.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # use the latest stable version in 5.x series
    }
  }
}


  provider "aws" {
  region  = var.aws_region
}
