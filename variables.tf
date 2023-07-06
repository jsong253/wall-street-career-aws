variable "region" {
    type = string
    description = "The region in which to create/manage resources"
    default = "us-east-1"
}
variable "account_id"{
  type          = string
  description   = "The account ID in which to create/manage resources"
  default       = "770646514888"
}

variable "env" {
    type = string
    description = "The region in which to create/manage resources"
    default = "Prod"
}
variable "shared_credentials_file" {
  description = "Profile file with credentials to the AWS account"
  type        = string
  default     = "~/.aws/credentials"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default ={
    application = "wall-street-carrer"
    env         = "Prod"
  }
}

variable "lambda_memory_size" {
  type = string
  description = "the memory size for the lambda"
  default = "128"
}

variable "lambda_timeout" {
  type = number
  description = "the timeout for the lambda"
  default = 10
}

variable "registration_table_name" {
  type          = string
  description   = "The name of the dynamodb registration table"
  default       = "registration_table"
}

variable "billing_mode" {
  type          = string
  description   = "The aws billing method"
  default       = "PROVISIONED"
}

variable "lambda_runtime"{
  type= string
  description = "version of the lambda"
  default= "nodejs14.x"
}

variable "feedback_table_name" {
  type          = string
  description   = "The name of the dynamodb feedback table"
  default       = "feedback_table"
}

variable "cors_allowed_origin" {
  type        = string
  description = "allow a given web application running at one origin (domain) to access selected resources from a server at a different origin"
  default     = "http://localhost:3000"
}