// https://registry.terraform.io/providers/hashicorp/aws/3.29.0/docs/resources/api_gateway_authorizer
// authorizer not triggerred:
// https://stackoverflow.com/questions/52549538/aws-api-gateway-custom-authorizer-not-invoked

/*
in case someone else struggles like i did to find out how to redeploy, click on API , then Resources 
(first link in the API, just above stages link) and then from actions dropdown on the top , choose on 
Deploy API option
*/
resource "aws_lambda_function" "request_authorize_lambda_function" {
  filename          = data.archive_file.get_feedback_authorize_lambda_archive_file.output_path
  function_name     = var.request_authorize_lambda_function_name
  description       = var.request_authorize_lambda_function_name
  memory_size       = var.lambda_memory_size
  timeout           = var.lambda_timeout
  runtime           = var.lambda_runtime
  architectures     = ["arm64"]
  handler           = "modules/request_authorize_lambda_function/index.handler"
  source_code_hash  = data.archive_file.get_feedback_authorize_lambda_archive_file.output_base64sha256        
  role              = aws_iam_role.lambda_assumed_role.arn

  // layers            = [ module.common_lambda_layer.common_lambda_layer_arn ]
  layers = [var.common_lambda_layer_arn]
  
  environment{
    variables={
        ENV                       = var.env
        REGION                    = var.region
        FEEDBACK_TABLE            = var.feedback_table_name
        FEEDBACK_TABLE_ARN        = var.feedback_table_arn
        CORS_ALLOWED_ORIGION      = ""
        RECORD_EXPIRATION_IN_DAYS = var.retention_in_days
    }
  }
}

resource "aws_cloudwatch_log_group" "request_authorize_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.request_authorize_lambda_function.function_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_iam_role" "lambda_assumed_role" {
  name = "lambda_assumed_role_feedback"

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

// iam policy
resource "aws_iam_policy" "get_feedback_lambda_policy" {
  name        = "get_feedback_lambda_policy_to_access_secret_manager"
  description = "allows lambda to get data from the sm"
  policy      = data.aws_iam_policy_document.get_feedback_lambda_policydoc.json
}

resource "aws_iam_role_policy_attachment" "get_feedback_lambda_policy_attachment" {
  role       = aws_iam_role.lambda_assumed_role.name
  policy_arn = aws_iam_policy.get_feedback_lambda_policy.arn
}


data "archive_file" "get_feedback_authorize_lambda_archive_file" {
  type        = "zip"
  output_path = "${path.module}/get_feedback_authorize_lambda_archive_file.zip"
  
  source {
    content   = "${file("terraform/modules/request_authorize_lambda_function/index.js")}"         // must be the full path
    filename  = "modules/request_authorize_lambda_function/index.js"
  }

  // must add all the js code in the same folder
  source {
    content   = "${file("terraform/modules/request_authorize_lambda_function/sm.js")}"          // must be the full path
    filename  = "modules/request_authorize_lambda_function/sm.js"
  }

  source {
    content   = "${file("terraform/modules/request_authorize_lambda_function/createLogger.js")}"   // must be the full path
    filename  = "modules/request_authorize_lambda_function/createLogger.js"
  }
}


// do not format the assume_role_policy code block otherwise you get tarraform apply error invalid policy
resource "aws_iam_role" "invocation_role_feedback" {
  name = "api_gateway_auth_invocation_feedback"
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
// allow rest api to invoke authorizer
resource "aws_iam_role_policy" "invocation_policy_feedback" {
  name = "aws_iam_role_policy_feedback"
  role = aws_iam_role.invocation_role_feedback.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.request_authorize_lambda_function.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "get_feedback_lambda_policy" {
  role       = aws_iam_role.lambda_assumed_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


data "aws_iam_policy_document" "get_feedback_lambda_policydoc" {
  statement {
    effect    = "Allow"
    actions = [
       "secretsmanager:*",
    ]
    resources = ["*"]
  }
}



