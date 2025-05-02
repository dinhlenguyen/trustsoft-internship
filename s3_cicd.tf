resource "aws_s3_bucket" "cicd_website" {
  bucket = "s3_cicd_internship_dinh"
  force_destroy = true             

  tags = {
    Name = "s3_cicd_internship_dinh"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.cicd_website.id

  versioning_configuration {
    status = "Enabled"
  }
}