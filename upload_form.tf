########################################
# S3 Bucket for photo uploads
########################################
resource "aws_s3_bucket" "upload_form" {
  bucket        = "s3-upload-form-internship-dinh"
  force_destroy = true

  tags = {
    Name = "s3_upload_form_internship_dinh"
  }
}

resource "aws_s3_bucket_versioning" "upload_versioning" {
  bucket = aws_s3_bucket.upload_form.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "uploads_block" {
  bucket                  = aws_s3_bucket.upload_form.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
########################################
# CORS configuration for browser upload
########################################
resource "aws_s3_bucket_cors_configuration" "upload_cors" {
  bucket = aws_s3_bucket.upload_form.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

########################################
# Cognito Identity Pool (for unauthenticated users)
########################################
resource "aws_cognito_identity_pool" "cognito_internship_dinh" {
  identity_pool_name               = "cognito_internship_dinh"
  allow_unauthenticated_identities = true
}

########################################
# IAM Role for Unauthenticated Users
########################################

data "aws_iam_policy_document" "unauth_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.cognito_internship_dinh.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

resource "aws_iam_role" "iam_cognito_internship_dinh" {
  name               = "iam_cognito_internship_dinh"
  assume_role_policy = data.aws_iam_policy_document.unauth_assume_role.json
}

########################################
# IAM Policy: PutObject only to S3 bucket
########################################

data "aws_iam_policy_document" "upload_to_s3" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.upload_form.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "s3_upload_internship_dinh" {
  name   = "s3_upload_internship_dinh"
  policy = data.aws_iam_policy_document.upload_to_s3.json
}

resource "aws_iam_role_policy_attachment" "cognito_s3_internship_dinh" {
  role       = aws_iam_role.iam_cognito_internship_dinh.name
  policy_arn = aws_iam_policy.s3_upload_internship_dinh.arn
}

########################################
# Attach IAM roles to Cognito Identity Pool
########################################

resource "aws_cognito_identity_pool_roles_attachment" "guest_roles" {
  identity_pool_id = aws_cognito_identity_pool.cognito_internship_dinh.id

  roles = {
    "unauthenticated" = aws_iam_role.iam_cognito_internship_dinh.arn
  }
}