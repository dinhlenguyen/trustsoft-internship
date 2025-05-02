terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "eu-west-1"
}

########################################
# S3 Bucket for Terraform State Backend + KMS encryption
########################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = "s3-backend-internship-dinh"

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "this" {
  description             = "Description for the KMS key used to encrypt Terraform state"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "statekey_internship_dinh"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.this.arn
    }
  }
}

########################################
# DynamoDB Table for Terraform State Locking
########################################

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "lockfile_internship_dinh"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
