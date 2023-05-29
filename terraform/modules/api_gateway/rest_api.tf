// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.
resource "aws_api_gateway_rest_api" "rest_api"{
    name = var.rest_api_name
    description="AWS rest api endpoints API Gateway"

}

resource "aws_api_gateway_resource" "rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "registrations"
}

resource "aws_api_gateway_method" "rest_api_get_method"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"          // use Cognito Authorizer
  // authorization = "NONE"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  provider_arns = [var.cognito_user_pool_arn]
}

resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_resource.id
  http_method             = aws_api_gateway_method.rest_api_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn
  connection_type         = "INTERNET"
}

resource "aws_api_gateway_method_response" "rest_api_get_method_response_200"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.rest_api_get_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_integration.rest_api_get_method_integration.http_method
  status_code = aws_api_gateway_method_response.rest_api_get_method_response_200.status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the registrations API!"
    })
  }
} 

//  Creating a lambda resource based policy to allow API gateway to invoke the lambda function:
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_get_method.http_method}${aws_api_gateway_resource.rest_api_resource.path}"
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  depends_on  =[
    aws_api_gateway_resource.rest_api_resource,
    aws_api_gateway_method.rest_api_get_method,
    aws_api_gateway_integration.rest_api_get_method_integration
  ]

  triggers      = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.rest_api_resource.id,
      aws_api_gateway_method.rest_api_get_method.id,
      aws_api_gateway_integration.rest_api_get_method_integration.id
    ]))
  }

  variables = {
    "deploy_ver" = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.rest_api_stage_name

  depends_on  =[
    aws_api_gateway_resource.rest_api_resource,
    aws_api_gateway_method.rest_api_get_method,
    aws_api_gateway_integration.rest_api_get_method_integration
  ]
}


# start of cors implementation

# adds OPTIONS rest handler to API Gateway to deal with CORS pre-flight checks

resource "aws_api_gateway_method" "registration_cors_resource_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "registration_cors_resource_options_method_response_200" {
  depends_on  = [aws_api_gateway_method.registration_cors_resource_options_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_method.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

resource "aws_api_gateway_integration" "registration_cors_resource_options_integration" {
  depends_on  = [aws_api_gateway_method.registration_cors_resource_options_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_method.http_method

  type        = "MOCK"                                                              # MOCK (not calling any real backend)

  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "registration_cors_resource_options_integraton_response" {
  depends_on  = [aws_api_gateway_method_response.registration_cors_resource_options_method_response_200]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_method.http_method
  status_code = aws_api_gateway_method_response.registration_cors_resource_options_method_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",    # Take note of the double and single quotation marks in the response_parameters property
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST'",
    # "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allowed_origin}'"
  }

  response_templates = {
    "application/json" = ""
  }
}
# end of cors implementation
