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
      DB_HOST       = "grayscale-metadata-db.choq86uu2zhq.eu-west-1.rds.amazonaws.com:3306"
      DB_USER       = "admin"
      DB_PASS       = var.db_password
      DB_NAME       = "grayscaledb"
    }
  }

  layers = [
    aws_lambda_layer_version.pillow_layer.arn
  ]

  depends_on = [aws_iam_role_policy.lambda_image_policy]
}
