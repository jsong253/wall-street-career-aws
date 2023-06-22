
variable "request_authorize_lambda_function_name" {
  type        = string
  description = "The name of the Lambda function for create-registrations endpoint"
  default     = "Request-Authorize-Feedback-Lambda"
}

variable "retention_in_days" {
  type        = number
  description = "The retention days for the lambda log"
  default     = 30
}

// 
variable "common_lambda_layer_arn"{
  type = string
  description = "the arn of the lambda layer for comon-lambda-layer"
}

variable "feedback_table_name" {
  type        = string
  description = "The name of the dynamodb registrtion table"
}

variable "feedback_table_arn" {
  type        = string
  description = "The arn of the dynamodb registrtion table"
}

variable "lambda_memory_size" {
  type = number
  description = "the memory size for the lambda"
}

variable "lambda_timeout" {
  type = number
  description = "the timeout for the lambda"
}

variable "lambda_runtime"{
  type= string
  description = "version of the lambda"
}

variable "env"{
  type        = string
  description = "The env for the lambda to run"
}

variable "region"{
  type        = string
  description = "The env for the lambda to run"
}

