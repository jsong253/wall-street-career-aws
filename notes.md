# terraform apply
PS C:\project area\wall-street-career-aws> terraform apply --auto-approve  
module.lambda_function.data.archive_file.lambda_code: Reading...
module.lambda_function.data.archive_file.lambda_code: Read complete after 0s [id=b04f3ee8f5e43fa3b162981b50bb72fe1acabb33]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.api_gateway.aws_api_gateway_integration.rest_api_get_method_integration will be created
  + resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
      + cache_namespace      = (known after apply)
      + connection_type      = "INTERNET"
      + http_method          = "GET"
      + id                   = (known after apply)
      + passthrough_behavior = (known after apply)
      + request_templates    = {
          + "application/json" = jsonencode(
                {
                  + statusCode = 200
                }
            )
        }
      + resource_id          = (known after apply)
      + rest_api_id          = (known after apply)
      + timeout_milliseconds = 29000
      + type                 = "MOCK"
    }

  # module.api_gateway.aws_api_gateway_integration_response.rest_api_get_method_integration_response_200 will be created
  + resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
      + http_method        = "GET"
      + id                 = (known after apply)
      + resource_id        = (known after apply)
      + response_templates = {
          + "application/json" = jsonencode(
                {
                  + body = "Hello from the registrations API!"
                }
            )
        }
      + rest_api_id        = (known after apply)
      + status_code        = "200"
    }

  # module.api_gateway.aws_api_gateway_method.rest_api_get_method will be created
  + resource "aws_api_gateway_method" "rest_api_get_method" {
      + api_key_required = false
      + authorization    = "NONE"
      + http_method      = "GET"
      + id               = (known after apply)
      + resource_id      = (known after apply)
      + rest_api_id      = (known after apply)
    }

  # module.api_gateway.aws_api_gateway_method_response.rest_api_get_method_response_200 will be created
  + resource "aws_api_gateway_method_response" "rest_api_get_method_response_200" {
      + http_method = "GET"
      + id          = (known after apply)
      + resource_id = (known after apply)
      + rest_api_id = (known after apply)
      + status_code = "200"
    }

  # module.api_gateway.aws_api_gateway_resource.rest_api_resource will be created
  + resource "aws_api_gateway_resource" "rest_api_resource" {
      + id          = (known after apply)
      + parent_id   = (known after apply)
      + path        = (known after apply)
      + path_part   = "registrations"
      + rest_api_id = (known after apply)
    }

  # module.api_gateway.aws_api_gateway_rest_api.rest_api will be created
  + resource "aws_api_gateway_rest_api" "rest_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = "AWS rest api endpoints"
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
      + id                           = (known after apply)
      + minimum_compression_size     = -1
      + name                         = "wall-street-career-api-gateway"
      + policy                       = (known after apply)
      + root_resource_id             = (known after apply)
      + tags_all                     = (known after apply)
    }

  # module.lambda_function.aws_cloudwatch_log_group.lambda_log_group will be created
  + resource "aws_cloudwatch_log_group" "lambda_log_group" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + name              = "/aws/lambda/RegistrationsLambda"
      + retention_in_days = 30
      + tags_all          = (known after apply)
    }

  # module.lambda_function.aws_iam_role.lambda_execution_role will be created
  + resource "aws_iam_role" "lambda_execution_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "lambda.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "lambda_execution_role_RegistrationsLambda"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)
    }

  # module.lambda_function.aws_iam_role_policy_attachment.lambda_policy will be created
  + resource "aws_iam_role_policy_attachment" "lambda_policy" {
      + id         = (known after apply)
      + policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      + role       = "lambda_execution_role_RegistrationsLambda"
    }

  # module.lambda_function.aws_lambda_function.lambda_function will be created
  + resource "aws_lambda_function" "lambda_function" {
      + architectures                  = (known after apply)
      + arn                            = (known after apply)
      + function_name                  = "RegistrationsLambda"
      + handler                        = "index.handler"
      + id                             = (known after apply)
      + invoke_arn                     = (known after apply)
      + last_modified                  = (known after apply)
      + memory_size                    = 128
      + package_type                   = "Zip"
      + publish                        = false
      + qualified_arn                  = (known after apply)
      + reserved_concurrent_executions = -1
      + role                           = (known after apply)
      + runtime                        = "nodejs14.x"
      + s3_bucket                      = (known after apply)
      + s3_key                         = "function_code.zip"
      + signing_job_arn                = (known after apply)
      + signing_profile_version_arn    = (known after apply)
      + source_code_hash               = "hznHbmgfkAkjuQDJ3w73XPQh05yrtUZQxLmtGbanbYU="
      + source_code_size               = (known after apply)
      + tags_all                       = (known after apply)
      + timeout                        = 3
      + version                        = (known after apply)

      + environment {
          + variables = {
              + "CORS_ALLOWED_ORIGION"      = ""
              + "ENV"                       = "dev"
              + "RECORD_EXPIRATION_IN_DAYS" = "185"
              + "REGION"                    = "us-east-1"
              + "REGISTRATION_TABLE"        = ""
              + "REGISTRATION_TABLE_ARN"    = ""
            }
        }
    }

  # module.lambda_function.aws_s3_bucket.lambda_bucket will be created
  + resource "aws_s3_bucket" "lambda_bucket" {
      + acceleration_status                  = (known after apply)
      + acl                                  = (known after apply)
      + arn                                  = (known after apply)
      + bucket                               = "s3-for-api-gateway-lambda-wsc-jlyaa"
      + bucket_domain_name                   = (known after apply)
      + bucket_regional_domain_name          = (known after apply)
      + cors_rule                            = (known after apply)
      + force_destroy                        = false
      + grant                                = (known after apply)
      + hosted_zone_id                       = (known after apply)
      + id                                   = (known after apply)
      + lifecycle_rule                       = (known after apply)
      + logging                              = (known after apply)
      + policy                               = (known after apply)
      + region                               = (known after apply)
      + replication_configuration            = (known after apply)
      + request_payer                        = (known after apply)
      + server_side_encryption_configuration = (known after apply)
      + tags_all                             = (known after apply)
      + versioning                           = (known after apply)
      + website                              = (known after apply)
      + website_domain                       = (known after apply)
      + website_endpoint                     = (known after apply)
    }

  # module.lambda_function.aws_s3_bucket_acl.lambda_bucket_acl will be created
  + resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
      + acl    = "private"
      + bucket = (known after apply)
      + id     = (known after apply)
    }

  # module.lambda_function.aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership will be created
  + resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + object_ownership = "ObjectWriter"
        }
    }

  # module.lambda_function.aws_s3_object.lambda_code will be created
  + resource "aws_s3_object" "lambda_code" {
      + acl                    = "private"
      + bucket                 = (known after apply)
      + bucket_key_enabled     = (known after apply)
      + content_type           = (known after apply)
      + etag                   = "76cdb2bad9582d23c1f6f4d868218d6c"
      + force_destroy          = false
      + id                     = (known after apply)
      + key                    = "function_code.zip"
      + kms_key_id             = (known after apply)
      + server_side_encryption = (known after apply)
      + source                 = "terraform/modules/lambda_function/function_code.zip"
      + storage_class          = (known after apply)
      + tags_all               = (known after apply)
      + version_id             = (known after apply)
    }
│     RequestID: "0d884bc1-8aee-46c5-897e-fd771bc36aaf"
│   },
│   Message_: "Uploaded file must be a non-empty zip",
│   Type: "User"
│ }
│
│   with module.lambda_function.aws_lambda_function.lambda_function,
│   on terraform\modules\lambda_function\lambda.tf line 35, in resource "aws_lambda_function" "lambda_function":
│   35: resource "aws_lambda_function" "lambda_function" {
│
╵
PS C:\project area\wall-street-career-aws>

# terraform destroy
PS C:\project area\wall-street-career-aws> terraform destroy --auto-approve
module.lambda_function.data.archive_file.lambda_code: Reading...
module.lambda_function.data.archive_file.lambda_code: Read complete after 0s [id=b04f3ee8f5e43fa3b162981b50bb72fe1acabb33]
module.api_gateway.aws_api_gateway_rest_api.rest_api: Refreshing state... [id=60txsg7cvb]
module.lambda_function.aws_iam_role.lambda_execution_role: Refreshing state... [id=lambda_execution_role_RegistrationsLambda]
module.lambda_function.aws_s3_bucket.lambda_bucket: Refreshing state... [id=s3-for-api-gateway-lambda-wsc-jlyaa]
module.api_gateway.aws_api_gateway_resource.rest_api_resource: Refreshing state... [id=ohrxee]
module.api_gateway.aws_api_gateway_method.rest_api_get_method: Refreshing state... [id=agm-60txsg7cvb-ohrxee-GET]
module.api_gateway.aws_api_gateway_method_response.rest_api_get_method_response_200: Refreshing state... [id=agmr-60txsg7cvb-ohrxee-GET-200]
module.api_gateway.aws_api_gateway_integration.rest_api_get_method_integration: Refreshing state... [id=agi-60txsg7cvb-ohrxee-GET]
module.api_gateway.aws_api_gateway_integration_response.rest_api_get_method_integration_response_200: Refreshing state... [id=agir-60txsg7cvb-ohrxee-GET-200]
module.lambda_function.aws_iam_role_policy_attachment.lambda_policy: Refreshing state... [id=lambda_execution_role_RegistrationsLambda-20230525122708350100000001]
module.lambda_function.aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership: Refreshing state... [id=s3-for-api-gateway-lambda-wsc-jlyaa]
module.lambda_function.aws_s3_object.lambda_code: Refreshing state... [id=function_code.zip]
module.lambda_function.aws_s3_bucket_acl.lambda_bucket_acl: Refreshing state... [id=s3-for-api-gateway-lambda-wsc-jlyaa,private]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # module.api_gateway.aws_api_gateway_integration.rest_api_get_method_integration will be destroyed
  - resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
      - cache_key_parameters = [] -> null
      - cache_namespace      = "ohrxee" -> null
      - connection_type      = "INTERNET" -> null
      - http_method          = "GET" -> null
      - id                   = "agi-60txsg7cvb-ohrxee-GET" -> null
      - passthrough_behavior = "WHEN_NO_MATCH" -> null
      - request_parameters   = {} -> null
      - request_templates    = {
          - "application/json" = jsonencode(
                {
                  - statusCode = 200
                }
            )
        } -> null
      - resource_id          = "ohrxee" -> null
      - rest_api_id          = "60txsg7cvb" -> null
      - timeout_milliseconds = 29000 -> null
      - type                 = "MOCK" -> null
    }

  # module.api_gateway.aws_api_gateway_integration_response.rest_api_get_method_integration_response_200 will be destroyed
  - resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
      - http_method         = "GET" -> null
      - id                  = "agir-60txsg7cvb-ohrxee-GET-200" -> null
      - resource_id         = "ohrxee" -> null
      - response_parameters = {} -> null
      - response_templates  = {
          - "application/json" = jsonencode(
                {
                  - body = "Hello from the registrations API!"
                }
            )
        } -> null
      - rest_api_id         = "60txsg7cvb" -> null
      - status_code         = "200" -> null
    }

  # module.api_gateway.aws_api_gateway_method.rest_api_get_method will be destroyed
  - resource "aws_api_gateway_method" "rest_api_get_method" {
      - api_key_required     = false -> null
      - authorization        = "NONE" -> null
      - authorization_scopes = [] -> null
      - http_method          = "GET" -> null
      - id                   = "agm-60txsg7cvb-ohrxee-GET" -> null
      - request_models       = {} -> null
      - request_parameters   = {} -> null
      - resource_id          = "ohrxee" -> null
      - rest_api_id          = "60txsg7cvb" -> null
    }

  # module.api_gateway.aws_api_gateway_method_response.rest_api_get_method_response_200 will be destroyed
  - resource "aws_api_gateway_method_response" "rest_api_get_method_response_200" {
      - http_method         = "GET" -> null
      - id                  = "agmr-60txsg7cvb-ohrxee-GET-200" -> null
      - resource_id         = "ohrxee" -> null
      - response_models     = {} -> null
      - response_parameters = {} -> null
      - rest_api_id         = "60txsg7cvb" -> null
      - status_code         = "200" -> null
    }

  # module.api_gateway.aws_api_gateway_resource.rest_api_resource will be destroyed
  - resource "aws_api_gateway_resource" "rest_api_resource" {
      - id          = "ohrxee" -> null
      - parent_id   = "f9s5m1ozpb" -> null
      - path        = "/registrations" -> null
      - path_part   = "registrations" -> null
      - rest_api_id = "60txsg7cvb" -> null
    }

  # module.api_gateway.aws_api_gateway_rest_api.rest_api will be destroyed
  - resource "aws_api_gateway_rest_api" "rest_api" {
      - api_key_source               = "HEADER" -> null
      - arn                          = "arn:aws:apigateway:us-east-1::/restapis/60txsg7cvb" -> null
      - binary_media_types           = [] -> null
      - created_date                 = "2023-05-25T12:27:06Z" -> null
      - description                  = "AWS rest api endpoints" -> null
      - disable_execute_api_endpoint = false -> null
      - execution_arn                = "arn:aws:execute-api:us-east-1:770646514888:60txsg7cvb" -> null
      - id                           = "60txsg7cvb" -> null
      - minimum_compression_size     = -1 -> null
      - name                         = "wall-street-career-api-gateway" -> null
      - root_resource_id             = "f9s5m1ozpb" -> null
      - tags                         = {} -> null
      - tags_all                     = {} -> null

      - endpoint_configuration {
          - types            = [
              - "EDGE",
            ] -> null
          - vpc_endpoint_ids = [] -> null
        }
    }

  # module.lambda_function.aws_iam_role.lambda_execution_role will be destroyed
  - resource "aws_iam_role" "lambda_execution_role" {
      - arn                   = "arn:aws:iam::770646514888:role/lambda_execution_role_RegistrationsLambda" -> null
      - assume_role_policy    = jsonencode(
            {
              - Statement = [
                  - {
                      - Action    = "sts:AssumeRole"
                      - Effect    = "Allow"
                      - Principal = {
                          - Service = "lambda.amazonaws.com"
                        }
                      - Sid       = ""
                    },
                ]
              - Version   = "2012-10-17"
            }
        ) -> null
      - create_date           = "2023-05-25T12:27:06Z" -> null
      - force_detach_policies = false -> null
      - id                    = "lambda_execution_role_RegistrationsLambda" -> null
      - managed_policy_arns   = [
          - "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        ] -> null
      - max_session_duration  = 3600 -> null
      - name                  = "lambda_execution_role_RegistrationsLambda" -> null
      - path                  = "/" -> null
      - tags                  = {} -> null
      - tags_all              = {} -> null
      - unique_id             = "AROA3G3Q4TTELTUDN2VCN" -> null

      - inline_policy {}
    }

  # module.lambda_function.aws_iam_role_policy_attachment.lambda_policy will be destroyed
  - resource "aws_iam_role_policy_attachment" "lambda_policy" {
      - id         = "lambda_execution_role_RegistrationsLambda-20230525122708350100000001" -> null
      - policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" -> null
      - role       = "lambda_execution_role_RegistrationsLambda" -> null
    }

  # module.lambda_function.aws_s3_bucket.lambda_bucket will be destroyed
  - resource "aws_s3_bucket" "lambda_bucket" {
      - acl                                  = "private" -> null
      - arn                                  = "arn:aws:s3:::s3-for-api-gateway-lambda-wsc-jlyaa" -> null
      - bucket                               = "s3-for-api-gateway-lambda-wsc-jlyaa" -> null
      - bucket_domain_name                   = "s3-for-api-gateway-lambda-wsc-jlyaa.s3.amazonaws.com" -> null
      - bucket_regional_domain_name          = "s3-for-api-gateway-lambda-wsc-jlyaa.s3.amazonaws.com" -> null
      - cors_rule                            = [] -> null
      - force_destroy                        = false -> null
      - grant                                = [] -> null
      - hosted_zone_id                       = "Z3AQBSTGFYJSTF" -> null
      - id                                   = "s3-for-api-gateway-lambda-wsc-jlyaa" -> null
      - lifecycle_rule                       = [] -> null
      - logging                              = [] -> null
      - region                               = "us-east-1" -> null
      - replication_configuration            = [] -> null
      - request_payer                        = "BucketOwner" -> null
      - server_side_encryption_configuration = [
          - {
              - rule = [
                  - {
                      - apply_server_side_encryption_by_default = [
                          - {
                              - kms_master_key_id = ""
                              - sse_algorithm     = "AES256"
                            },
                        ]
                      - bucket_key_enabled                      = false
                    },
                ]
            },
        ] -> null
      - tags                                 = {} -> null
      - tags_all                             = {} -> null
      - versioning                           = [
          - {
              - enabled    = false
              - mfa_delete = false
            },
        ] -> null
      - website                              = [] -> null
    }

  # module.lambda_function.aws_s3_bucket_acl.lambda_bucket_acl will be destroyed
  - resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
      - acl    = "private" -> null
      - bucket = "s3-for-api-gateway-lambda-wsc-jlyaa" -> null
      - id     = "s3-for-api-gateway-lambda-wsc-jlyaa,private" -> null

      - access_control_policy {
          - grant {
              - permission = "FULL_CONTROL" -> null

              - grantee {
                  - display_name = "songjianzhong16" -> null
                  - id           = "2a6c2a1a528372af259a7d32bf0bbee5cf2b508f1d2ecd057022856156f8cd57" -> null
                  - type         = "CanonicalUser" -> null
                }
            }
          - owner {
              - display_name = "songjianzhong16" -> null
              - id           = "2a6c2a1a528372af259a7d32bf0bbee5cf2b508f1d2ecd057022856156f8cd57" -> null
            }
        }
    }

  # module.lambda_function.aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership will be destroyed
  - resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
      - bucket = "s3-for-api-gateway-lambda-wsc-jlyaa" -> null
      - id     = "s3-for-api-gateway-lambda-wsc-jlyaa" -> null

      - rule {
          - object_ownership = "ObjectWriter" -> null
        }
    }

module.api_gateway.aws_api_gateway_method_response.rest_api_get_method_response_200: Destruction complete after 0s
module.api_gateway.aws_api_gateway_integration.rest_api_get_method_integration: Destruction complete after 0s
module.api_gateway.aws_api_gateway_method.rest_api_get_method: Destroying... [id=agm-60txsg7cvb-ohrxee-GET]
module.api_gateway.aws_api_gateway_method.rest_api_get_method: Destruction complete after 0s
module.api_gateway.aws_api_gateway_resource.rest_api_resource: Destroying... [id=ohrxee]
module.lambda_function.aws_s3_bucket.lambda_bucket: Destruction complete after 0s
module.api_gateway.aws_api_gateway_resource.rest_api_resource: Destruction complete after 0s
module.api_gateway.aws_api_gateway_rest_api.rest_api: Destroying... [id=60txsg7cvb]
module.api_gateway.aws_api_gateway_rest_api.rest_api: Destruction complete after 0s
module.lambda_function.aws_iam_role.lambda_execution_role: Destruction complete after 1s

Destroy complete! Resources: 12 destroyed.
PS C:\project area\wall-street-career-aws>

// invoke lambda function from CLI
PS C:\project area\wall-street-career-aws> aws lambda invoke --function-name RegistrationsLambda response.json

// execute get method in the broswer: 
https://jlmie38mea.execute-api.us-east-1.amazonaws.com/prod/registrations

# postman: https://jlmie38mea.execute-api.us-east-1.amazonaws.com/prod/registrations


# errors when CORS are not set up on the aws rest api end point: Access to fetch at 'https://rtkuir7kpi.execute-api.us-east-1.amazonaws.com/prod/registrations' from origin 'http://localhost:3000' has been blocked by CORS policy: Response to preflight request doesn't pass access control check: No 'Access-Control-Allow-Origin' header is present on the requested resource. If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.

# after adding the OPTIONS method and tried again:
  Access to fetch at 'https://aaiiuxs4r8.execute-api.us-east-1.amazonaws.com/prod/registrations' from origin 'http://localhost:3000' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource. If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.

  Access to fetch at 'https://aaiiuxs4r8.execute-api.us-east-1.amazonaws.com/prod/registrations' from origin 'http://localhost:3000' has been blocked by CORS policy: Request header field access-control-allow-origin is not allowed by Access-Control-Allow-Headers in preflight response.

  Access to fetch at 'https://aaiiuxs4r8.execute-api.us-east-1.amazonaws.com/prod/registrations' from origin 'http://localhost:3000' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource. If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.


  # aws console GET request test:
  Request: /registrations
Status: 200
Latency: 391 ms
Response Body
{"movies":["Schindlers List","Shawshank Redemption","Batman The Dark Knight","Spider-Man : No Way Home","Avengers"]}
Response Headers
{"Access-Control-Allow-Headers":["Content-Type"],"Access-Control-Allow-Methods":["OPTIONS,GET"],"Access-Control-Allow-Origin":["*"],"Content-Type":["application/json"],"X-Amzn-Trace-Id":["Root=1-64754fe5-084fc11dc5ca6bb8641894f5;Sampled=0"]}
Logs
Execution log for request 4b8ae478-ac2d-4fff-96e9-870739d88db2
Tue May 30 01:22:45 UTC 2023 : Starting execution for request: 4b8ae478-ac2d-4fff-96e9-870739d88db2
Tue May 30 01:22:45 UTC 2023 : HTTP Method: GET, Resource Path: /registrations
Tue May 30 01:22:45 UTC 2023 : Method request path: {}
Tue May 30 01:22:45 UTC 2023 : Method request query string: {}
Tue May 30 01:22:45 UTC 2023 : Method request headers: {}
Tue May 30 01:22:45 UTC 2023 : Method request body before transformations: 
Tue May 30 01:22:45 UTC 2023 : Endpoint request URI: https://lambda.us-east-1.amazonaws.com/2015-03-31/functions/arn:aws:lambda:us-east-1:770646514888:function:RegistrationsLambda/invocations
Tue May 30 01:22:45 UTC 2023 : Endpoint request headers: {X-Amz-Date=20230530T012245Z, x-amzn-apigateway-api-id=aaiiuxs4r8, Accept=application/json, User-Agent=AmazonAPIGateway_aaiiuxs4r8, Host=lambda.us-east-1.amazonaws.com, X-Amz-Content-Sha256=e453252d2d015ca2c209e05da741b0b5b42d280f9b76573e2ef5c34781a7edfc, X-Amzn-Trace-Id=Root=1-64754fe5-084fc11dc5ca6bb8641894f5, x-amzn-lambda-integration-tag=4b8ae478-ac2d-4fff-96e9-870739d88db2, Authorization=*********************************************************************************************************************************************************************************************************************************************************************************************************************************************4822f2, X-Amz-Source-Arn=arn:aws:execute-api:us-east-1:770646514888:aaiiuxs4r8/test-invoke-stage/GET/registrations, X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEkaCXVzLWVhc3QtMSJGMEQCICbvbNhWR/g95DQUgucWl5+TNk0Rc8n8/iWWvtueaHWSAiAClhg+EVYl1OetRS2eS6usD5IjfsnQhw3TaWM5BDQ3syq6 [TRUNCATED]
Tue May 30 01:22:45 UTC 2023 : Endpoint request body after transformations: {"resource":"/registrations","path":"/registrations","httpMethod":"GET","headers":null,"multiValueHeaders":null,"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"ic4ebg","resourcePath":"/registrations","httpMethod":"GET","extendedRequestId":"Ftlr2FI1IAMFUuA=","requestTime":"30/May/2023:01:22:45 +0000","path":"/registrations","accountId":"770646514888","protocol":"HTTP/1.1","stage":"test-invoke-stage","domainPrefix":"testPrefix","requestTimeEpoch":1685409765146,"requestId":"4b8ae478-ac2d-4fff-96e9-870739d88db2","identity":{"cognitoIdentityPoolId":null,"cognitoIdentityId":null,"apiKey":"test-invoke-api-key","principalOrgId":null,"cognitoAuthenticationType":null,"userArn":"arn:aws:iam::770646514888:root","apiKeyId":"test-invoke-api-key-id","userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36","accountId": [TRUNCATED]
Tue May 30 01:22:45 UTC 2023 : Sending request to https://lambda.us-east-1.amazonaws.com/2015-03-31/functions/arn:aws:lambda:us-east-1:770646514888:function:RegistrationsLambda/invocations
Tue May 30 01:22:45 UTC 2023 : Received response. Status: 200, Integration latency: 388 ms
Tue May 30 01:22:45 UTC 2023 : Endpoint response headers: {Date=Tue, 30 May 2023 01:22:45 GMT, Content-Type=application/json, Content-Length=327, Connection=keep-alive, x-amzn-RequestId=30d10735-7c5d-42a5-89d5-91097fc146f4, x-amzn-Remapped-Content-Length=0, X-Amz-Executed-Version=$LATEST, X-Amzn-Trace-Id=root=1-64754fe5-084fc11dc5ca6bb8641894f5;sampled=0}
Tue May 30 01:22:45 UTC 2023 : Endpoint response body before transformations: {"statusCode":200,"headers":{"Content-Type":"application/json","Access-Control-Allow-Headers":"Content-Type","Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"OPTIONS,GET"},"body":"{\"movies\":[\"Schindlers List\",\"Shawshank Redemption\",\"Batman The Dark Knight\",\"Spider-Man : No Way Home\",\"Avengers\"]}"}
Tue May 30 01:22:45 UTC 2023 : Method response body after transformations: {"movies":["Schindlers List","Shawshank Redemption","Batman The Dark Knight","Spider-Man : No Way Home","Avengers"]}
Tue May 30 01:22:45 UTC 2023 : Method response headers: {Content-Type=application/json, Access-Control-Allow-Headers=Content-Type, Access-Control-Allow-Origin=*, Access-Control-Allow-Methods=OPTIONS,GET, X-Amzn-Trace-Id=Root=1-64754fe5-084fc11dc5ca6bb8641894f5;Sampled=0}
Tue May 30 01:22:45 UTC 2023 : Successfully completed execution
Tue May 30 01:22:45 UTC 2023 : Method completed with status: 200

# aws console OPTIONS test:
Request: /registrations
Status: 200
Latency: 5 ms
Response Body
no data
Response Headers
{"Access-Control-Allow-Headers":["Content-Type"],"Access-Control-Allow-Methods":["GET,OPTIONS"],"Access-Control-Allow-Origin":["*"],"Content-Type":["application/json"]}
Logs
Execution log for request bbda39d8-9df9-41aa-95c1-5c779acb8433
Tue May 30 01:31:59 UTC 2023 : Starting execution for request: bbda39d8-9df9-41aa-95c1-5c779acb8433
Tue May 30 01:31:59 UTC 2023 : HTTP Method: OPTIONS, Resource Path: /registrations
Tue May 30 01:31:59 UTC 2023 : Method request path: {}
Tue May 30 01:31:59 UTC 2023 : Method request query string: {}
Tue May 30 01:31:59 UTC 2023 : Method request headers: {}
Tue May 30 01:31:59 UTC 2023 : Method request body before transformations: 
Tue May 30 01:31:59 UTC 2023 : Method response body after transformations: 
Tue May 30 01:31:59 UTC 2023 : Method response headers: {Access-Control-Allow-Headers=Content-Type, Access-Control-Allow-Methods=GET,OPTIONS, Access-Control-Allow-Origin=*, Content-Type=application/json}
Tue May 30 01:31:59 UTC 2023 : Successfully completed execution
Tue May 30 01:31:59 UTC 2023 : Method completed with status: 200

# postman test:
https://aaiiuxs4r8.execute-api.us-east-1.amazonaws.com/prod/registrations?email=songjianzhong16@gmail.com&password=Jianpassword

# cURL command to generate okta token
C:\Users\Yang>curl -X POST -u "0oa130rmd72AXU1zI0h8:SOWxjMxm-0l650KJe5fD41f4kxbvGqsBle74nwjp" -d "grant_type=client_credentials" https://travelers-dev.oktapreview.com/oauth2/aus130rsqrd51M6HQ0h8/v1/token -d "scope=filetracking-write"