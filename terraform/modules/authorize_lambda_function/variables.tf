
variable "authorize_lambda_function_name" {
  type        = string
  description = "The name of the Lambda function for create-registrations endpoint"
  default     = "Authorize-Registrations-Lambda"
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
