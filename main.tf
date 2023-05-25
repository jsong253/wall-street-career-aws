module "api_gateway" {
  source = "./terraform/modules/api_gateway"
  # api_gateway_region = var.region
}

module "lambda_function" {
  source = "./terraform/modules/lambda_function"
}