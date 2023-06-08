// https://registry.terraform.io/providers/hashicorp/aws/3.29.0/docs/resources/api_gateway_authorizer
// authorizer not triggerred:
// https://stackoverflow.com/questions/52549538/aws-api-gateway-custom-authorizer-not-invoked
resource "aws_lambda_function" "authorize_lambda_function" {
  filename          = data.archive_file.get_registrations_authorize_lambda_archive_file.output_path
  function_name     = var.authorize_lambda_function_name
  description       = var.authorize_lambda_function_name
  runtime           = "nodejs14.x"
  handler           = "modules/authorize_lambda_function/index.handler"
  source_code_hash  = data.archive_file.get_registrations_authorize_lambda_archive_file.output_base64sha256        
  role              = aws_iam_role.lambda.arn
  
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

resource "aws_cloudwatch_log_group" "authorize_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.authorize_lambda_function.function_name}"
  retention_in_days = var.retention_in_days
}


resource "aws_iam_role" "lambda" {
  name = "demo-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// alternate way to archive lambda without using s3 bucket to store lambda zip file
// used without s3
data "archive_file" "get_registrations_authorize_lambda_archive_file" {
  type        = "zip"
  output_path = "${path.module}/get_registrations_authorize_lambda_archive_file.zip"
  source {
    content   = "${file("terraform/modules/authorize_lambda_function/index.js")}"         // must be the full path
    filename  = "modules/authorize_lambda_function/index.js"
  }
}


// do not format the policy 
resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// do not format the policy 
resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.authorize_lambda_function.arn}"
    }
  ]
}
EOF
}



