terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45"    # Or latest stable version; lock to major version
    }
  }

  required_version = ">= 1.3.0"    # Or match your Terraform CLI version
}

provider "aws" {
  region = var.aws_region    # Read region from variable
}