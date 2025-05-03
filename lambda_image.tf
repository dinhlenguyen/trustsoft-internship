########################################
# S3 bucket for transformed images
########################################
resource "aws_s3_bucket" "transformed_images" {
  bucket = "s3-lambda-internship-dinh"
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
  filename            = "${path.module}/lambda-grayscale/packaged/pil.zip"
  layer_name          = "grayscale_internship_dinh"
  compatible_runtimes = ["python3.9"]
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
    }
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
