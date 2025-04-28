terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45"
    }
  }

  required_version = ">= 1.3.0"

  backend "s3" {
    bucket         = "s3-backend-internship-dinh"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "lockfile_internship_dinh"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}