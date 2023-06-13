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
  // shared_credentials_files = [var.shared_credentials_file]
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
  authorize_lambda_function_name = module.authorize_lambda_function.authorize_lambda_function_name
  get_lambda_function_arn = module.get_lambda_function.get_lambda_function_arn
  create_lambda_function_arn = module.create_lambda_function.create_lambda_function_arn
  authorize_lambda_function_invoke_arn = module.authorize_lambda_function.authorize_lambda_function_invoke_arn
  authorize_lambda_invocation_role_arn = module.authorize_lambda_function.authorize_lambda_invocation_role_arn
  depends_on = [
    module.get_lambda_function,
    module.create_lambda_function,
    module.authorize_lambda_function
  ]
}

module "get_lambda_function" {
  source = "./terraform/modules/get_lambda_function"
}

module "create_lambda_function" {
  source = "./terraform/modules/create_lambda_function"
}

module "authorize_lambda_function" {
  source = "./terraform/modules/authorize_lambda_function"
  common_lambda_layer_arn = module.lambda_layer.lambda_layer_arn
}


module "lambda_layer" {
  source =  "./terraform/modules/lambda_layer"   
}

