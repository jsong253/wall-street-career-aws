// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.

// https://dev.to/mxglt/declare-a-simple-rest-api-gateway-terraform-5ci5          // sub resources
resource "aws_api_gateway_rest_api" "rest_api"{
    name = var.rest_api_name
    description="AWS rest api endpoints API Gateway"
}

// get-registrations endpoint
resource "aws_api_gateway_resource" "rest_api_get_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "get-registrations"
}

resource "aws_api_gateway_request_validator" "rest_api_get_method_validator" {
  name                        = "get_registrations-method-validator"
  rest_api_id                 = aws_api_gateway_rest_api.rest_api.id
  validate_request_body       = false
  validate_request_parameters = true
}

resource "aws_api_gateway_authorizer" "rest_api_authorizer" {
  name                              = "api-gateway-authorizer-${var.env}"
  rest_api_id                       = aws_api_gateway_rest_api.rest_api.id
  // authorizer_uri                    = aws_lambda_function.authorize_lambda.invoke_arn
  authorizer_uri                    = var.authorize_lambda_function_invoke_arn     

  // authorizer_credentials            = aws_iam_role.invocation_role.arn
  authorizer_credentials            = var.authorize_lambda_invocation_role_arn
  
  //authorizer_result_ttl_in_seconds  = var.authorizer_cache_time
  authorizer_result_ttl_in_seconds  = 3600                            // Defaults to 300
  type                              = "TOKEN"
  identity_source                   = "method.request.header.Authorization"
  identity_validation_expression    = "^(Bearer )[a-zA-Z0-9\\-_]+?\\.[a-zA-Z0-9\\-_]+?\\.([a-zA-Z0-9\\-_]+)$"
}

resource "aws_api_gateway_method" "rest_api_get_method"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_get_resource.id
  http_method = "GET"
  // authorization = "NONE"                // no authorizer
  authorization = "CUSTOM"            // "CUSTOM"
  
  request_validator_id = aws_api_gateway_request_validator.rest_api_get_method_validator.id
  authorizer_id        = aws_api_gateway_authorizer.rest_api_authorizer.id     // to enable the authorizer, uncomment this line and change to authorization = "CUSTOM"  

  request_parameters   = {
    "method.request.querystring.email"          = false,
    "method.request.querystring.password"       = false,
  }

  api_key_required     = false
}

resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_get_resource.id
  http_method             = aws_api_gateway_method.rest_api_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.get_lambda_function_arn
  connection_type         = "INTERNET"
}

resource "aws_api_gateway_method_response" "rest_api_get_method_response_200"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_get_resource.id
  http_method = aws_api_gateway_method.rest_api_get_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_get_resource.id
  http_method = aws_api_gateway_integration.rest_api_get_method_integration.http_method
  status_code = aws_api_gateway_method_response.rest_api_get_method_response_200.status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the get-registrations API!"
    })
  }
} 

// Creating a authorize lambda resource based policy to allow API gateway to invoke the authorize lambda function:
resource "aws_lambda_permission" "api_gateway_authorize_lambda" {
  statement_id  = "AllowExecutionAuthorizeLambdaFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.authorize_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/authorizers/${aws_api_gateway_authorizer.rest_api_authorizer.id}"
  depends_on    = [aws_api_gateway_rest_api.rest_api, aws_api_gateway_authorizer.rest_api_authorizer]
}

//  Creating a lambda resource based policy to allow API gateway to invoke the lambda function:
resource "aws_lambda_permission" "api_gateway_get_lambda" {
  statement_id  = "AllowExecutionGetLambdaFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.get_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_get_method.http_method}${aws_api_gateway_resource.rest_api_get_resource.path}"
  // source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
  depends_on    = [aws_api_gateway_rest_api.rest_api, aws_api_gateway_method.rest_api_get_method, aws_api_gateway_resource.rest_api_get_resource]
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  depends_on  =[
    aws_api_gateway_resource.rest_api_get_resource,
    aws_api_gateway_method.rest_api_get_method,
    aws_api_gateway_integration.rest_api_get_method_integration,
    
    aws_api_gateway_resource.rest_api_create_resource,
    aws_api_gateway_method.rest_api_create_method,
    aws_api_gateway_integration.rest_api_create_method_integration,

    aws_api_gateway_resource.rest_api_feedback_resource,
    aws_api_gateway_method.rest_api_feedback_get_method,
    aws_api_gateway_integration.rest_api_feedback_get_method_integration,

    aws_api_gateway_method.rest_api_feedback_create_method,
    aws_api_gateway_integration.rest_api_feedback_create_method_integration,
  ]

  triggers      = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.rest_api_get_resource.id,
      aws_api_gateway_method.rest_api_get_method.id,
      aws_api_gateway_integration.rest_api_get_method_integration.id,
      
      aws_api_gateway_resource.rest_api_create_resource.id,
      aws_api_gateway_method.rest_api_create_method.id,
      aws_api_gateway_integration.rest_api_create_method_integration.id,

      aws_api_gateway_resource.rest_api_feedback_resource.id,
      aws_api_gateway_method.rest_api_feedback_get_method.id,
      aws_api_gateway_integration.rest_api_feedback_get_method_integration.id,

      aws_api_gateway_method.rest_api_feedback_create_method.id,
      aws_api_gateway_integration.rest_api_feedback_create_method_integration.id,
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
    aws_api_gateway_resource.rest_api_get_resource,
    aws_api_gateway_method.rest_api_get_method,
    aws_api_gateway_integration.rest_api_get_method_integration,
    
    aws_api_gateway_resource.rest_api_create_resource,
    aws_api_gateway_method.rest_api_create_method,
    aws_api_gateway_integration.rest_api_create_method_integration,

    aws_api_gateway_resource.rest_api_feedback_resource,
    aws_api_gateway_method.rest_api_feedback_get_method,
    aws_api_gateway_integration.rest_api_feedback_get_method_integration,

    aws_api_gateway_method.rest_api_feedback_create_method,
    aws_api_gateway_integration.rest_api_feedback_create_method_integration,
  ]
}

# start of cors implementation for registrations end point
# adds OPTIONS rest handler to API Gateway to deal with CORS pre-flight checks
resource "aws_api_gateway_method" "registration_cors_resource_options_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_get_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "registration_cors_resource_options_get_method_response_200" {
  depends_on  = [aws_api_gateway_method.registration_cors_resource_options_get_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_get_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_get_method.http_method
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

resource "aws_api_gateway_integration" "registration_cors_resource_options_get_integration" {
  depends_on  = [aws_api_gateway_method.registration_cors_resource_options_get_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_get_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_get_method.http_method

  type        = "MOCK"                                                              # MOCK (not calling any real backend)

  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "registration_cors_resource_options_integraton_get_response" {
  depends_on  = [aws_api_gateway_method_response.registration_cors_resource_options_get_method_response_200]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_get_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_get_method.http_method
  status_code = aws_api_gateway_method_response.registration_cors_resource_options_get_method_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type','Authorization'",    # Take note of the double and single quotation marks in the response_parameters property
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    # "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allowed_origin}'"
  }

  response_templates = {
    "application/json" = ""
  }
}
# end of cors implementation


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////start create-registrations endpoint /////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// create-registrations endpoint

resource "aws_api_gateway_request_validator" "rest_api_create_method_validator" {
  name                        = "create_registration-method-validator"
  rest_api_id                 = aws_api_gateway_rest_api.rest_api.id
  validate_request_body       = true
  validate_request_parameters = false
}

resource "aws_api_gateway_resource" "rest_api_create_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "create-registrations"
}

resource "aws_api_gateway_method" "rest_api_create_method"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_create_resource.id
  http_method = "POST"
  // authorization = "NONE"                // no authorizer
  authorization = "CUSTOM"            // "CUSTOM"
  
  request_validator_id = aws_api_gateway_request_validator.rest_api_create_method_validator.id
  authorizer_id        = aws_api_gateway_authorizer.rest_api_authorizer.id        // to enable the authorizer, uncomment this line and change Authorization = "CUSTOM"

  # request_models = {
  #   "application/json" = aws_api_gateway_model.rest_api_create_method__model.name
  # }

  api_key_required     = false
}

resource "aws_api_gateway_integration" "rest_api_create_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_create_resource.id
  http_method             = aws_api_gateway_method.rest_api_create_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.create_lambda_function_arn
  connection_type         = "INTERNET"
}

# resource "aws_api_gateway_model" "rest_api_create_method__model" {
#   rest_api_id  = aws_api_gateway_rest_api.rest_api.id
#   name         = "create-registrations-model${upper(var.env)}"
#   description  = "create-registrations Message Model in JSON format"
#   content_type = "application/json"
#   schema       = file("common/schema/publishStatus.json")
# }


resource "aws_api_gateway_method_response" "rest_api_create_method_response_200"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_create_resource.id
  http_method = aws_api_gateway_method.rest_api_create_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rest_api_create_method_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_create_resource.id
  http_method = aws_api_gateway_integration.rest_api_create_method_integration.http_method
  status_code = aws_api_gateway_method_response.rest_api_create_method_response_200.status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the registrations API!"
    })
  }
} 

//  Creating a lambda resource based policy to allow API gateway to invoke the lambda function:
resource "aws_lambda_permission" "api_gateway_create_lambda" {
  statement_id  = "AllowExecutionCreateLambdaFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.create_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_create_method.http_method}${aws_api_gateway_resource.rest_api_create_resource.path}"

  // source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
  depends_on    = [aws_api_gateway_rest_api.rest_api, aws_api_gateway_method.rest_api_create_method, aws_api_gateway_resource.rest_api_create_resource]
}

# start of cors implementation for create-registrations
# adds OPTIONS rest handler to API Gateway to deal with CORS pre-flight checks
resource "aws_api_gateway_method" "registration_cors_resource_options_create_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_create_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "registration_cors_resource_options_create_method_response_200" {
  depends_on  = [aws_api_gateway_method.registration_cors_resource_options_create_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_create_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_create_method.http_method
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

resource "aws_api_gateway_integration" "registration_cors_resource_options_create_integration" {
  depends_on  = [aws_api_gateway_method.registration_cors_resource_options_create_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_create_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_create_method.http_method

  type        = "MOCK"                                                              # MOCK (not calling any real backend)

  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "registration_cors_resource_options_create_integraton_response" {
  depends_on  = [aws_api_gateway_method_response.registration_cors_resource_options_create_method_response_200]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_create_resource.id
  http_method = aws_api_gateway_method.registration_cors_resource_options_create_method.http_method
  status_code = aws_api_gateway_method_response.registration_cors_resource_options_create_method_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type','Authorization'",    # Take note of the double and single quotation marks in the response_parameters property
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    # "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allowed_origin}'"
  }

  response_templates = {
    "application/json" = ""
  }
}
# end of cors implementation


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////feedback endpoint///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

// //////////////////////feedback top level endpoint
resource "aws_api_gateway_resource" "rest_api_feedback_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "feedbacks"
}

resource "aws_api_gateway_request_validator" "rest_api_feedback_get_method_validator" {
  name                        = "feedbacks-get-method-validator"
  rest_api_id                 = aws_api_gateway_rest_api.rest_api.id
  validate_request_body       = false
  validate_request_parameters = true
}

resource "aws_api_gateway_request_validator" "rest_api_feedback_create_method_validator" {
  name                        = "feedbacks-create-method-validator"
  rest_api_id                 = aws_api_gateway_rest_api.rest_api.id
  validate_request_body       = true
  validate_request_parameters = false
}

resource "aws_api_gateway_authorizer" "rest_api_request_authorizer" {
  name                              = "api-gateway-request-authorizer-${var.env}"
  rest_api_id                       = aws_api_gateway_rest_api.rest_api.id
  authorizer_uri                    = var.request_authorize_lambda_function_invoke_arn     
  authorizer_credentials            = var.request_authorize_lambda_invocation_role_arn
  
  //authorizer_result_ttl_in_seconds  = var.authorizer_cache_time
  authorizer_result_ttl_in_seconds  = "0"                            // Defaults to 300
  type                              = "REQUEST"
  identity_source                   = "method.request.header.WSC-SHAREDSECRET"
}

///////////////////////////////////////////////////////////////////////////////////////////////
// /////////////////////////////////////get-feedback endpoint///////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
resource "aws_api_gateway_method" "rest_api_feedback_get_method"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_feedback_resource.id
  http_method = "GET"
  authorization = "NONE"                // no authorizer
  // authorization = "CUSTOM"            // "CUSTOM"
  
  request_validator_id = aws_api_gateway_request_validator.rest_api_feedback_get_method_validator.id
  authorizer_id        = aws_api_gateway_authorizer.rest_api_request_authorizer.id     

  request_parameters   = {
    "method.request.querystring.email"          = false,
  }

  api_key_required     = false
}

// https://stackoverflow.com/questions/41371970/accessdeniedexception-unable-to-determine-service-operation-name-to-be-authoriz
resource "aws_api_gateway_integration" "rest_api_feedback_get_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_feedback_resource.id
  http_method             = aws_api_gateway_method.rest_api_feedback_get_method.http_method
  // integration_http_method = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.feedback_get_lambda_function_arn
  connection_type         = "INTERNET"
}

resource "aws_api_gateway_method_response" "rest_api_feedback_get_method_response_200"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_feedback_resource.id
  http_method = aws_api_gateway_method.rest_api_feedback_get_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rest_api_feedback_get_method_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_feedback_resource.id
  http_method = aws_api_gateway_integration.rest_api_feedback_get_method_integration.http_method
  status_code = aws_api_gateway_method_response.rest_api_feedback_get_method_response_200.status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the get-registrations API!"
    })
  }
} 

//  Creating a lambda resource based policy to allow API gateway to invoke the lambda function:
resource "aws_lambda_permission" "api_gateway_feedback_get_lambda" {
  statement_id  = "AllowExecutionFeedbackGetLambdaFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.feedback_get_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_feedback_get_method.http_method}${aws_api_gateway_resource.rest_api_feedback_resource.path}"
  // source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
  depends_on    = [aws_api_gateway_rest_api.rest_api, aws_api_gateway_method.rest_api_feedback_get_method, aws_api_gateway_resource.rest_api_feedback_resource]
}


// ////////////////////////////////////POST//////////////////////////////
// ///////////////////////////////////////create-feedback endpoint
resource "aws_api_gateway_method" "rest_api_feedback_create_method"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_feedback_resource.id
  http_method = "POST"
  authorization = "NONE"                // no authorizer
  // authorization = "CUSTOM"            // "CUSTOM"
  
  request_validator_id = aws_api_gateway_request_validator.rest_api_feedback_create_method_validator.id
  // authorizer_id        = aws_api_gateway_authorizer.rest_api_authorizer.id     // to enable the authorizer, uncomment this line and change to authorization = "CUSTOM"  

  api_key_required     = false
}

resource "aws_api_gateway_integration" "rest_api_feedback_create_method_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_feedback_resource.id
  http_method             = aws_api_gateway_method.rest_api_feedback_create_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.feedback_create_lambda_function_arn
  connection_type         = "INTERNET"
}

resource "aws_api_gateway_method_response" "rest_api_feedback_create_method_response_200"{
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_feedback_resource.id
  http_method = aws_api_gateway_method.rest_api_feedback_create_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rest_api_feedback_create_method_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_feedback_resource.id
  http_method = aws_api_gateway_integration.rest_api_feedback_create_method_integration.http_method
  status_code = aws_api_gateway_method_response.rest_api_feedback_create_method_response_200.status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the get-registrations API!"
    })
  }
} 

//  Creating a lambda resource based policy to allow API gateway to invoke the lambda function:
resource "aws_lambda_permission" "api_gateway_feedback_create_lambda" {
  statement_id  = "AllowExecutionFeedbackCreateLambdaFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.feedback_create_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_feedback_create_method.http_method}${aws_api_gateway_resource.rest_api_feedback_resource.path}"
  // source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
  depends_on    = [aws_api_gateway_rest_api.rest_api, aws_api_gateway_method.rest_api_feedback_create_method, aws_api_gateway_resource.rest_api_feedback_resource]
}




