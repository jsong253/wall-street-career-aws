variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
  default     = "s3-for-api-gateway-lambda-wsc-jlyaa" // must be unique - change this to something unique
}
variable "create_lambda_function_name" {
  type        = string
  description = "The name of the Lambda function for create-registrations endpoint"
  default     = "Create-Registrations-Lambda"
}

variable "retention_in_days" {
  type        = number
  description = "The retention days for the lambda log"
  default     = 30
}

variable "lambda_memory_size"{
  type        = number
  description = "The max memory size for the lambda"
  default     = 30000
}

variable "lambda_timeout"{
  type        = number
  description = "The timeout for the lambda to run"
  default     = 3600
}