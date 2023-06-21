// https://repost.aws/knowledge-center/lambda-kmsaccessdeniedexception-errors
resource "aws_lambda_function" "feedback_create_lambda_function" {
  filename          = data.archive_file.create_feedback_create_lambda_archive_file.output_path
  function_name     = var.feedback_create_lambda_function_name
  description       = var.feedback_create_lambda_function_name
  runtime           = var.lambda_runtime
  handler           = "modules/create_lambda_function/index.handler"
  source_code_hash  = data.archive_file.create_feedback_create_lambda_archive_file.output_base64sha256        
  role              = aws_iam_role.feedback_create_lambda_execution_role.arn
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout
  architectures    = ["arm64"]

  layers = [var.common_lambda_layer_arn]

  environment{
    variables={
        ENV=var.env
        REGION                    =var.region
        FEEDBACK_TABLE        = var.feedback_table_name
        FEEDBACK_TABLE_ARN    =  var.feedback_table_arn
        CORS_ALLOWED_ORIGION      ="*"
        RECORD_EXPIRATION_IN_DAYS =var.record_expiration_in_days
    }
  }
}

resource "aws_cloudwatch_log_group" "feedback_create_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.feedback_create_lambda_function.function_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_iam_role" "feedback_create_lambda_execution_role" {
  name = "lambda_execution_role_${var.feedback_create_lambda_function_name}"
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

// allow apigateway to execute the lambda
resource "aws_iam_role_policy_attachment" "create_lambda_policy_feedback" {
  role       = aws_iam_role.feedback_create_lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// allow lambda to access dynamodb table
resource "aws_iam_role_policy" "dynamodb-lambda-policy-feedback" {
   name = "allow_feedback_lambda_to_access_dynamodb_policy"
   role = aws_iam_role.feedback_create_lambda_execution_role.id
   policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
           "Effect" : "Allow",
           "Action" : ["dynamodb:*"],
           "Resource" : "${var.feedback_table_arn}"
        }
      ]
   })
}

// allow lamnda to access dynamodb table kms key to deencript table data
resource "aws_iam_role_policy" "kms-lambda-policy-feedback" {
   name = "allow_feedback_lambda_to_access_dynamodb_kms_policy"
   role = aws_iam_role.feedback_create_lambda_execution_role.id
   policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
           "Effect" : "Allow",
           "Action" : ["kms:*"],
           "Resource" : "${var.dynamodb_kms-key-arn}"             //  "Resource": "your-KMS-key-arn"
        }
      ]
   })
}

// alternate way to archive lambda without using s3 bucket to store lambda zip file
// used without s3
data "archive_file" "create_feedback_create_lambda_archive_file" {
  type        = "zip"
  output_path = "${path.module}/create_feedback_create_lambda_archive_file.zip"
  source {
    content   = "${file("terraform/modules/feedback_create_lambda_function/index.js")}"         // must be the full path
    filename  = "modules/feedback_create_lambda_function/index.js"
  }

   source {
    content   = "${file("terraform/common/ddb.js")}"         // must be the full path
    filename  = "modules/feedback_create_lambda_function/ddb.js"
  }
}



