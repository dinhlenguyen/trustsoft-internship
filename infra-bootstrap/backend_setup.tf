########################################
# S3 Bucket for Terraform State Backend
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

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
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
