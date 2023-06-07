// archive lambda code without s3
resource "aws_lambda_function" "create_lambda_function" {
  filename          = data.archive_file.get_registrations_create_lambda_archive_file.output_path
  function_name     = var.create_lambda_function_name
  description       = var.create_lambda_function_name
  runtime           = "nodejs14.x"
  handler           = "modules/create_lambda_function/index.handler"
  source_code_hash  = data.archive_file.get_registrations_create_lambda_archive_file.output_base64sha256        
  role              = aws_iam_role.create_lambda_execution_role.arn
  // memory_size       = var.lambda_memory_size
  // timeout           = var.lambda_timeout

  environment{
    variables={
        ENV="dev"
        REGION="us-east-1"
        REGISTRATION_TABLE = ""
        REGISTRATION_TABLE_ARN = ""
        CORS_ALLOWED_ORIGION=""
        RECORD_EXPIRATION_IN_DAYS="185"
    }
  }
}

resource "aws_cloudwatch_log_group" "create_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.create_lambda_function.function_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_iam_role" "create_lambda_execution_role" {
  name = "lambda_execution_role_${var.create_lambda_function_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "create_lambda_policy" {
  role       = aws_iam_role.create_lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// alternate way to archive lambda without using s3 bucket to store lambda zip file
// used without s3
data "archive_file" "get_registrations_create_lambda_archive_file" {
  type        = "zip"
  output_path = "${path.module}/get_registrations_create_lambda_archive_file.zip"
  source {
    content   = "${file("terraform/modules/create_lambda_function/index.js")}"         // must be the full path
    filename  = "modules/create_lambda_function/index.js"
  }
}