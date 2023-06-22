// https://registry.terraform.io/providers/hashicorp/aws/3.29.0/docs/resources/api_gateway_authorizer
// authorizer not triggerred:
// https://stackoverflow.com/questions/52549538/aws-api-gateway-custom-authorizer-not-invoked

/*
in case someone else struggles like i did to find out how to redeploy, click on API , then Resources 
(first link in the API, just above stages link) and then from actions dropdown on the top , choose on 
Deploy API option
*/
resource "aws_lambda_function" "authorize_lambda_function" {
  filename          = data.archive_file.get_registrations_authorize_lambda_archive_file.output_path
  function_name     = var.authorize_lambda_function_name
  description       = var.authorize_lambda_function_name
  memory_size       = var.lambda_memory_size
  timeout           = var.lambda_timeout
  runtime           = var.lambda_runtime
  architectures     = ["arm64"]
  handler           = "modules/authorize_lambda_function/index.handler"
  source_code_hash  = data.archive_file.get_registrations_authorize_lambda_archive_file.output_base64sha256        
  role              = aws_iam_role.lambda.arn

  // layers            = [ module.common_lambda_layer.common_lambda_layer_arn ]
  layers = [var.common_lambda_layer_arn]
  
  environment{
    variables={
        ENV                         = var.env
        REGION                      = var.region
        REGISTRATION_TABLE          = var.registration_table_name
        REGISTRATION_TABLE_ARN      = var.registration_table_arn
        CORS_ALLOWED_ORIGION        = ""
        RECORD_EXPIRATION_IN_DAYS   = var.retention_in_days
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

  // must add all the js code in the same folder
  source {
    content   = "${file("terraform/modules/authorize_lambda_function/okta.js")}"          // must be the full path
    filename  = "modules/authorize_lambda_function/okta.js"
  }

  source {
    content   = "${file("terraform/modules/authorize_lambda_function/createLogger.js")}"   // must be the full path
    filename  = "modules/authorize_lambda_function/createLogger.js"
  }
}


// do not format the assume_role_policy code block otherwise you get tarraform apply error invalid policy
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

// do not format the policy code block otherwise you get tarraform apply error invalid policy
resource "aws_iam_role_policy" "invocation_policy" {
  name = "aws_iam_role_policy_registration"
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

resource "aws_iam_role_policy_attachment" "get_lambda_policy" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



