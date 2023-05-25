//using archive_file data source to zip the lambda code:
// The below code would generate a function_code.zip file inside the lambda_function module.
data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/"
  output_path = "${path.module}/function_code.zip"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket_name
}
//making the s3 bucket private as it houses the lambda code:
resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]       // to resolve AccessControlListNotSupported: The bucket does not allow ACLs status code: 400
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
# https://stackoverflow.com/questions/76049290/error-accesscontrollistnotsupported-when-trying-to-create-a-bucket-acl-in-aws
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "function_code.zip"
  source = data.archive_file.lambda_code.output_path
  etag   = filemd5(data.archive_file.lambda_code.output_path)
}

resource "aws_lambda_function" "lambda_function" {
  // filename = data.archive_file.get_registrations_lambda_archive_file.output_path
  function_name    = var.lambda_function_name
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_code.key
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_code.output_base64sha256
  // source_code_hash = data.archive_file.get_registrations_lambda_archive_file.output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn

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
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = var.retention_in_days
}
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_${var.lambda_function_name}"
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
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# alternate way to archive lambda without using s3 bucket to store lambda zip file
# data "archive_file" "get_registrations_lambda_archive_file" {
#   type        = "zip"
 
#   output_path = "${path.module}/get_registrations_lambda_archive_file.zip"
#   source {
#     content     = "${file("modules/lambda_function/index.js")}"
#     filename    = "modules/lambda_function/index.js"
#   }
# }
