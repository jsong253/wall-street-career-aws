//using archive_file data source to zip the lambda code:
// The below code would generate a function_code.zip file inside the lambda_function module.
# data "archive_file" "lambda_code" {
#   type        = "zip"
#   source_dir  = "${path.module}/"
#   output_path = "${path.module}/function_code.zip"
# }

# resource "aws_s3_bucket" "lambda_bucket" {
#   bucket = var.s3_bucket_name
# }
# //making the s3 bucket private as it houses the lambda code:
# resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   acl    = "private"
#   depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]       // to resolve AccessControlListNotSupported: The bucket does not allow ACLs status code: 400
# }

# # Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
# # https://stackoverflow.com/questions/76049290/error-accesscontrollistnotsupported-when-trying-to-create-a-bucket-acl-in-aws
# resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   rule {
#     object_ownership = "ObjectWriter"
#   }
# }

# resource "aws_s3_object" "lambda_code" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   key    = "function_code.zip"
#   source = data.archive_file.lambda_code.output_path
#   etag   = filemd5(data.archive_file.lambda_code.output_path)
# }

// archive lambda code with s3
# resource "aws_lambda_function" "lambda_function" {
#   filename = data.archive_file.get_registrations_lambda_archive_file.output_path
#   function_name    = var.lambda_function_name
#   description      = var.lambda_function_name
#   s3_bucket        = aws_s3_bucket.lambda_bucket.id                         // used with s3 bucket
#   s3_key           = aws_s3_object.lambda_code.key                          // used with s3 bucket
#   source_code_hash = data.archive_file.lambda_code.output_base64sha256      // used with s3 bucket
#   runtime          = "nodejs14.x"
#   handler          = "modules/lambda_function/index.handler"
#   role             = aws_iam_role.lambda_execution_role.arn
# }

// archive lambda code without s3
resource "aws_lambda_function" "get_lambda_function" {
  filename = data.archive_file.get_registrations_get_lambda_archive_file.output_path
  function_name    = var.get_lambda_function_name
  description      = var.get_lambda_function_name
  runtime          = var.lambda_runtime
  handler          = "modules/get_lambda_function/index.handler"
  source_code_hash = data.archive_file.get_registrations_get_lambda_archive_file.output_base64sha256        
  role             = aws_iam_role.get_lambda_assumed_role.arn
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout
  architectures    = ["arm64"]

  layers = [var.common_lambda_layer_arn]
  
  environment{
    variables={
        ENV=var.env
        REGION=var.region
        REGISTRATION_TABLE = var.registration_table_name
        REGISTRATION_TABLE_ARN = var.registration_table_arn
        CORS_ALLOWED_ORIGION="*"
        RECORD_EXPIRATION_IN_DAYS=var.record_expiration_in_days
    }
  }
}
resource "aws_cloudwatch_log_group" "get_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.get_lambda_function.function_name}"
  retention_in_days = var.retention_in_days
}

// lambda assumed role
resource "aws_iam_role" "get_lambda_assumed_role" {
  name               = "lambda_assumed_role_${var.get_lambda_function_name}"
  description        = "Assumed Role for Lambda"
  assume_role_policy = data.aws_iam_policy_document.lambdatrustpolicy.json
}


// role policy for creation of logs
resource "aws_iam_role_policy_attachment" "get_registration_lambda_logs_attachment" {
  role       = aws_iam_role.get_lambda_assumed_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# // role policy attacchment to assume lambda_execution_role
# resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRoleForGetUploadDiagnostics" {
#     role       = aws_iam_role.get_lambda_assumed_role.name
#     policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }


// iam policy
resource "aws_iam_policy" "get_registration_lambda_policy" {
  name        = "get_registration_lambda_policy_to_access_dynamodb"
  description = "allows lambda to get data from the dynamoDB"
  policy      = data.aws_iam_policy_document.get_registration_lambda_policydoc.json
}

resource "aws_iam_role_policy_attachment" "get_registration_lambda_policy_attachment" {
  role       = aws_iam_role.get_lambda_assumed_role.name
  policy_arn = aws_iam_policy.get_registration_lambda_policy.arn
}


// alternate way to archive lambda without using s3 bucket to store lambda zip file
// used without s3
data "archive_file" "get_registrations_get_lambda_archive_file" {
  type        = "zip"
  output_path = "${path.module}/get_registrations_get_lambda_archive_file.zip"
  source {
    content   = "${file("terraform/modules/get_lambda_function/index.js")}"         // must be the full path
    filename  = "modules/get_lambda_function/index.js"
  }
}

data "aws_iam_policy_document" "get_registration_lambda_policydoc" {
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

