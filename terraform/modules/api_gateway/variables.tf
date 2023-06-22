variable "rest_api_name"{
    type = string
    description = "Name of the API Gateway created"
    default = "wall-street-career-api-gateway"
}

variable "api_gateway_region" {
  type        = string
  description = "The region in which to create/manage resources"
} 

//value comes from main.tf
variable "api_gateway_account_id" {
  type        = string
  description = "The account ID in which to create/manage resources"
} 

//value comes from main.tf
variable "get_lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
} 


//value comes from main.tf
variable "authorize_lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
}

//value comes from main.tf
variable "request_authorize_lambda_function_name" {
  type        = string
  description = "The name of the request authorize lambda function"
}

//value comes from main.tf
variable "get_lambda_function_arn" {
  type        = string
  description = "The ARN of the Lambda function"
} 

//value comes from main.tf
variable "create_lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
}


//value comes from main.tf
variable "create_lambda_function_arn" {
  type        = string
  description = "The ARN of the Lambda function"
} 

//value comes from main.tf
variable "authorize_lambda_function_invoke_arn" {
  type        = string
  description = "The ARN of the Lambda function"
}  

//value comes from main.tf
variable "rest_api_stage_name" {
  type        = string
  description = "The name of the API Gateway stage"
  default     = "prod" //add a stage name as per your requirement
}

//value comes from main.tf
variable "authorize_lambda_invocation_role_arn" {
  type        = string
}

variable "cors_allowed_origin" {
  type        = string
  description = "The allowed origins of the browser"
  default     = "http://localhost:3000"
}

variable "account_id"{
  type          = string
  description   = "The account ID in which to create/manage resources"
  default       = "770646514888"
}

variable "env" {
    type = string
    description = "The region in which to create/manage resources"
    default = "test"
}

variable "retention_in_days" {
  type        = number
  description = "The retention days for the lambda log"
  default     = 30
}

//value comes from main.tf
variable "feedback_get_lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
}


//value comes from main.tf
variable "feedback_get_lambda_function_arn" {
  type        = string
  description = "The ARN of the Lambda function"
} 

//value comes from main.tf
variable "feedback_create_lambda_function_name" {
  type        = string
  description = "The name of the Lambda function"
}


//value comes from main.tf
variable "feedback_create_lambda_function_arn" {
  type        = string
  description = "The ARN of the Lambda function"
} 

//value comes from main.tf
variable "request_authorize_lambda_function_invoke_arn" {
  type        = string
  description = "The ARN of the Lambda function"
}  

//value comes from main.tf
variable "request_authorize_lambda_invocation_role_arn" {
  type        = string
}
