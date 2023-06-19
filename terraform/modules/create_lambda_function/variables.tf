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

variable "env"{
  type        = string
  description = "The env for the lambda to run"
}

variable "region"{
  type        = string
  description = "The env for the lambda to run"
}

variable "registration_table_name" {
  type        = string
  description = "The name of the dynamodb registrtion table"
}

variable "registration_table_arn" {
  type        = string
  description = "The arn of the dynamodb registrtion table"
}

variable "record_expiration_in_days" {
  type        = number
  description = "The items or records of the dynamodb registrtion table to be removed from the table after a certain days"
  default = 365
}

variable "common_lambda_layer_arn"{
  type = string
  description = "the arn of the lambda layer for comon-lambda-layer"
}

variable "dynamodb_kms-key-arn" {
  type = string
  description = "the arn of the dynamodb kms key"
}

variable "lambda_memory_size" {
  type = number
  description = "the memory size for the lambda"
}

variable "lambda_timeout" {
  type = number
  description = "the timeout for the lambda"
} 

variable "cors_allowed_origin" {
  type = string
  description = "allowed origion to call lambda function"
}

variable "lambda_runtime"{
  type= string
  description = "version of the lambda"
}