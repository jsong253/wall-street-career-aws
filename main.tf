terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region                  = var.region
  // profile                 = var.aws_profile
  // shared_credentials_files = [var.shared_credentials_file]       // ["$HOME/.aws/credentials"]
  default_tags {
    tags = var.tags
  }
}

module "api_gateway" {
  source = "./terraform/modules/api_gateway"
  api_gateway_region = var.region
  api_gateway_account_id = var.account_id
  get_lambda_function_name = module.get_lambda_function.get_lambda_function_name
  create_lambda_function_name = module.create_lambda_function.create_lambda_function_name
  feedback_get_lambda_function_name = module.feedback_get_lambda_function.feedback_get_lambda_function_name
  feedback_create_lambda_function_name = module.feedback_create_lambda_function.feedback_create_lambda_function_name
  authorize_lambda_function_name = module.authorize_lambda_function.authorize_lambda_function_name

  request_authorize_lambda_function_name = module.request_authorize_lambda_function.request_authorize_lambda_function_name

  get_lambda_function_arn = module.get_lambda_function.get_lambda_function_arn
  create_lambda_function_arn = module.create_lambda_function.create_lambda_function_arn
  feedback_get_lambda_function_arn = module.feedback_get_lambda_function.feedback_get_lambda_function_arn
  feedback_create_lambda_function_arn = module.feedback_create_lambda_function.feedback_create_lambda_function_arn
  authorize_lambda_function_invoke_arn = module.authorize_lambda_function.authorize_lambda_function_invoke_arn
  authorize_lambda_invocation_role_arn = module.authorize_lambda_function.authorize_lambda_invocation_role_arn

  request_authorize_lambda_function_invoke_arn = module.request_authorize_lambda_function.request_authorize_lambda_function_invoke_arn
  request_authorize_lambda_invocation_role_arn = module.request_authorize_lambda_function.request_authorize_lambda_invocation_role_arn
  
  cors_allowed_origin = var.cors_allowed_origin

  depends_on = [
    module.get_lambda_function,
    module.create_lambda_function,
    module.authorize_lambda_function,
    module.delete_lambda_function,
    module.feedback_get_lambda_function,
    module.request_authorize_lambda_function,
  ]
}

module "get_lambda_function" {
  source = "./terraform/modules/get_lambda_function"
  registration_table_name = module.dynamodb_registration_table.registration_table_id
  registration_table_arn = module.dynamodb_registration_table.registration_table_arn
  region = var.region
  env = var.env
  common_lambda_layer_arn = module.lambda_layer.lambda_layer_arn
  lambda_memory_size      = var.lambda_memory_size
  lambda_timeout          = var.lambda_timeout
  lambda_runtime          = var.lambda_runtime
  cors_allowed_origin     = var.cors_allowed_origin
}

module "create_lambda_function" {
  source = "./terraform/modules/create_lambda_function"
  registration_table_name = module.dynamodb_registration_table.registration_table_id
  registration_table_arn = module.dynamodb_registration_table.registration_table_arn
  region = var.region
  env = var.env
  common_lambda_layer_arn = module.lambda_layer.lambda_layer_arn
  dynamodb_kms-key-arn    = module.dynamodb_registration_table.dynamo_kms_key_arn
  lambda_memory_size      = var.lambda_memory_size
  lambda_timeout          = var.lambda_timeout
  lambda_runtime          = var.lambda_runtime
  cors_allowed_origin     = var.cors_allowed_origin
}


module "delete_lambda_function" {
  source = "./terraform/modules/delete_lambda_function"
  registration_table_name = module.dynamodb_registration_table.registration_table_id
  registration_table_arn = module.dynamodb_registration_table.registration_table_arn
  region = var.region
  env = var.env
  common_lambda_layer_arn = module.lambda_layer.lambda_layer_arn
  dynamodb_kms-key-arn    = module.dynamodb_registration_table.dynamo_kms_key_arn
  lambda_memory_size      = var.lambda_memory_size
  lambda_timeout          = var.lambda_timeout
  lambda_runtime          = var.lambda_runtime
  cors_allowed_origin     = var.cors_allowed_origin
}

module "authorize_lambda_function" {
  source                  = "./terraform/modules/authorize_lambda_function"
  common_lambda_layer_arn = module.lambda_layer.lambda_layer_arn
  registration_table_name = module.dynamodb_registration_table.registration_table_id
  registration_table_arn  = module.dynamodb_registration_table.registration_table_arn
  lambda_memory_size      = var.lambda_memory_size
  lambda_timeout          = var.lambda_timeout
  lambda_runtime          = var.lambda_runtime
  region                  = var.region
  env                     = var.env
}

module "request_authorize_lambda_function" {
  source                  = "./terraform/modules/request_authorize_lambda_function"
  common_lambda_layer_arn = module.lambda_layer.lambda_layer_arn
  feedback_table_name     = module.dynamodb_feedback_table.feedback_table_id
  feedback_table_arn      = module.dynamodb_feedback_table.feedback_table_arn
  lambda_memory_size      = var.lambda_memory_size
  lambda_timeout          = var.lambda_timeout
  lambda_runtime          = var.lambda_runtime
  region                  = var.region
  env                     = var.env
}

module "lambda_layer" {
  source =  "./terraform/modules/lambda_layer"   
}

module  "dynamodb_registration_table" { 
   source                   = "./terraform/modules/dynamodb_registration_table" 
   env                      = var.env
   registration_table_name  = var.registration_table_name
   billing_mode             = var.billing_mode
}

module  "dynamodb_feedback_table" { 
   source                   = "./terraform/modules/dynamodb_feedback_table" 
   env                      = var.env
   feedback_table_name      = var.feedback_table_name
   billing_mode             = var.billing_mode
}


module "feedback_get_lambda_function" {
  source = "./terraform/modules/feedback_get_lambda_function"
  feedback_table_name = module.dynamodb_feedback_table.feedback_table_id
  feedback_table_arn = module.dynamodb_feedback_table.feedback_table_arn
  region = var.region
  env = var.env
  common_lambda_layer_arn = module.lambda_layer.lambda_layer_arn
  lambda_memory_size      = var.lambda_memory_size
  lambda_timeout          = var.lambda_timeout
  lambda_runtime          = var.lambda_runtime
  cors_allowed_origin     = var.cors_allowed_origin
}


module "feedback_create_lambda_function" {
  source = "./terraform/modules/feedback_create_lambda_function"
  feedback_table_name = module.dynamodb_feedback_table.feedback_table_id
  feedback_table_arn = module.dynamodb_feedback_table.feedback_table_arn
  region = var.region
  env = var.env
  common_lambda_layer_arn = module.lambda_layer.lambda_layer_arn
  dynamodb_kms-key-arn    = module.dynamodb_feedback_table.dynamo_kms_key_arn
  lambda_memory_size      = var.lambda_memory_size
  lambda_timeout          = var.lambda_timeout
  lambda_runtime          = var.lambda_runtime
  cors_allowed_origin     = var.cors_allowed_origin
}


