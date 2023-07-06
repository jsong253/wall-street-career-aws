resource "aws_lambda_function" "feedback_get_lambda_function" {
  filename = data.archive_file.get_feedback_get_lambda_archive_file.output_path
  function_name    = var.feedback_get_lambda_function_name
  description      = var.feedback_get_lambda_function_name
  runtime          = var.lambda_runtime
  handler          = "modules/feedback_get_lambda_function/index.handler"
  source_code_hash = data.archive_file.get_feedback_get_lambda_archive_file.output_base64sha256        
  role             = aws_iam_role.feedback_get_lambda_assumed_role.arn
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout
  architectures    = ["arm64"]

  layers = [var.common_lambda_layer_arn]
  
  environment{
    variables={
        ENV=var.env
        REGION=var.region
        REGISTRATION_TABLE = var.feedback_table_name
        REGISTRATION_TABLE_ARN = var.feedback_table_arn
        CORS_ALLOWED_ORIGION="*"
        RECORD_EXPIRATION_IN_DAYS=var.record_expiration_in_days
    }
  }
}
resource "aws_cloudwatch_log_group" "feedback_get_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.feedback_get_lambda_function.function_name}"
  retention_in_days = var.retention_in_days
}

// lambda assumed role
resource "aws_iam_role" "feedback_get_lambda_assumed_role" {
  name               = "lambda_assumed_role_${var.feedback_get_lambda_function_name}"
  description        = "Assumed Role for Lambda"
  assume_role_policy = data.aws_iam_policy_document.lambdatrustpolicy.json
}


// role policy for creation of logs
resource "aws_iam_role_policy_attachment" "get_feedback_lambda_logs_attachment" {
  role       = aws_iam_role.feedback_get_lambda_assumed_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// iam policy
resource "aws_iam_policy" "get_feedback_lambda_policy" {
  name        = "get_feedback_lambda_policy_to_access_dynamodb"
  description = "allows lambda to get data from the dynamoDB"
  policy      = data.aws_iam_policy_document.get_feedback_lambda_policydoc.json
}

resource "aws_iam_role_policy_attachment" "get_registration_lambda_policy_attachment" {
  role       = aws_iam_role.feedback_get_lambda_assumed_role.name
  policy_arn = aws_iam_policy.get_feedback_lambda_policy.arn
}


// alternate way to archive lambda without using s3 bucket to store lambda zip file
// used without s3
data "archive_file" "get_feedback_get_lambda_archive_file" {
  type        = "zip"
  output_path = "${path.module}/get_feedback_get_lambda_archive_file.zip"
  
  source {
    content   = "${file("terraform/modules/feedback_get_lambda_function/index.js")}"         // must be the full path
    filename  = "modules/feedback_get_lambda_function/index.js"
  }

  source {
    content   = "${file("terraform/common/createLogger.js")}"         // must be the full path
    filename  = "modules/feedback_get_lambda_function/createLogger.js"
  }
}

data "aws_iam_policy_document" "get_feedback_lambda_policydoc" {
  statement {
    effect    = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListShards",
      "dynamodb:ListStreams"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "lambdatrustpolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    sid = ""
  }
}

