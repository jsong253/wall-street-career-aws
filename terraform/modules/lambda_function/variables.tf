variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
  default     = "s3-for-api-gateway-lambda-wsc-jlyaa" // must be unique - change this to something unique
}
variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
  default     = "RegistrationsLambda"
}

variable "retention_in_days" {
  type        = number
  description = "The retention days for the lambda log"
  default     = 30
}

