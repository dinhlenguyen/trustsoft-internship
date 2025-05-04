########################################
# S3 bucket for transformed images
########################################
resource "aws_s3_bucket" "transformed_images" {
  bucket        = "s3-lambda-internship-dinh"
  force_destroy = true

  tags = {
    Name = "s3_lambda_internship_dinh"
  }
}

resource "aws_s3_bucket_public_access_block" "transformed_block" {
  bucket                  = aws_s3_bucket.transformed_images.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.transformed_images.id

  depends_on = [
    aws_s3_bucket_public_access_block.transformed_block
  ]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicRead",
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "arn:aws:s3:::s3-lambda-internship-dinh/*"
      }
    ]
  })
}

########################################
# Data source to generate an archive from file
########################################
data "archive_file" "function_package" {
  type        = "zip"
  source_file = "${path.root}/lambda-grayscale/lambda_function.py"
  output_path = "${path.root}/lambda-grayscale/packaged/lambda_function.zip"
}

########################################
# Lambda Layer for Pillow (built manually)
########################################

resource "aws_lambda_layer_version" "pillow_layer" {
  filename            = "${path.module}/lambda-grayscale/packaged/layer.zip"
  layer_name          = "grayscale_internship_dinh"
  compatible_runtimes = ["python3.9"]
}

########################################
# Lambda security group
########################################
resource "aws_security_group" "lambda_internship_dinh" {
  name        = "sg_lambda_internship_dinh"
  description = "Allow Lambda to access RDS"
  vpc_id      = aws_vpc.vpc_internship_dinh.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_lambda_internship_dinh"
  }
}

########################################
# Lambda Role
########################################

resource "aws_iam_role" "lambda_image_role" {
  name = "lambda_internship_dinh"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_image_policy" {
  role = aws_iam_role.lambda_image_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:*"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = "arn:aws:s3:::s3-upload-form-internship-dinh/*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "arn:aws:s3:::s3-lambda-internship-dinh/*"
      }
    ]
  })
}

########################################
# Lambda Function (Grayscale Converter)
########################################

resource "aws_lambda_function" "grayscale_image_processor" {
  function_name = "grayscale-image-converter"
  role          = aws_iam_role.lambda_image_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/lambda-grayscale/packaged/lambda_function.zip"
  timeout       = 10

  environment {
    variables = {
      TARGET_BUCKET = "s3-lambda-internship-dinh"
      DB_HOST       = "grayscale-metadata-db.choq86uu2zhq.eu-west-1.rds.amazonaws.com"
      DB_USER       = "admin"
      DB_PASS       = var.db_password
      DB_NAME       = "grayscaledb"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    security_group_ids = [aws_security_group.lambda_internship_dinh.id]
  }
  
  layers = [
    aws_lambda_layer_version.pillow_layer.arn
  ]

  depends_on = [aws_iam_role_policy.lambda_image_policy]
}

########################################
# S3 Trigger: Process images on upload
########################################

resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.grayscale_image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::s3-upload-form-internship-dinh"
}

resource "aws_s3_bucket_notification" "trigger_on_upload" {
  bucket = "s3-upload-form-internship-dinh"

  lambda_function {
    lambda_function_arn = aws_lambda_function.grayscale_image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_trigger]
}
