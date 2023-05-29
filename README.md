# wall-street-career-aws

# npm init -y to create package.json file
# npm i standard -D
# npm i -D jest jest-junit-reporter
# npm i aws-sdk
# create a providers.tf, api_gateway.tf and run terafrom init, terraform validate and terraform plan
    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.

    PS C:\project area\wall-street-career> terraform validate
    Success! The configuration is valid.

    PS C:\project area\wall-street-career> terraform plan
    - api_gateway in terraform\modules\api_gateway

  + resource "aws_api_gateway_rest_api" "rest_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = (known after apply)
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
  + resource "aws_api_gateway_rest_api" "rest_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = (known after apply)
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
      + id                           = (known after apply)
      + minimum_compression_size     = -1
      + name                         = "wall-street-career-api-gateway"
      + policy                       = (known after apply)
      + root_resource_id             = (known after apply)
      + tags_all                     = (known after apply)
    }

    Plan: 1 to add, 0 to change, 0 to destroy.

    terraform apply --auto-approve
    Plan: 1 to add, 0 to change, 0 to destroy.
    module.api_gateway.aws_api_gateway_rest_api.rest_api: Creating...
    module.api_gateway.aws_api_gateway_rest_api.rest_api: Creation complete after 1s [id=svti29yzs0]

    PS C:\project area\wall-street-career-aws> terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.api_gateway.aws_api_gateway_rest_api.rest_api will be created
  + resource "aws_api_gateway_rest_api" "rest_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = (known after apply)
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
      + id                           = (known after apply)
      + minimum_compression_size     = -1
      + name                         = "wall-street-career-api-gateway"
      + policy                       = (known after apply)
      + root_resource_id             = (known after apply)
      + tags_all                     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
module.api_gateway.aws_api_gateway_rest_api.rest_api: Creating...
module.api_gateway.aws_api_gateway_rest_api.rest_api: Creation complete after 1s [id=svti29yzs0]

      - endpoint_configuration {
          - types            = [
              - "EDGE",
            ] -> null
          - vpc_endpoint_ids = [] -> null
        }
    }

    Plan: 0 to add, 0 to change, 1 to destroy.

    Do you really want to destroy all resources?
    Terraform will destroy all your managed infrastructure, as shown above.
    There is no undo. Only 'yes' will be accepted to confirm.

    Enter a value: yes

    module.api_gateway.aws_api_gateway_rest_api.rest_api: Destroying... [id=svti29yzs0]
    module.api_gateway.aws_api_gateway_rest_api.rest_api: Destruction complete after 1s

    Destroy complete! Resources: 1 destroyed.
    PS C:\project area\wall-street-career-aws>

    or run: terraform destroy --auto-approve

    PS C:\project area\wall-street-career-aws> terraform destroy --auto-approve
module.api_gateway.aws_api_gateway_rest_api.rest_api: Refreshing state... [id=czkzvnhnki]
module.api_gateway.aws_api_gateway_resource.rest_api_resource: Refreshing state... [id=zgw63z]
module.api_gateway.aws_api_gateway_method.rest_api_get_method: Refreshing state... [id=agm-czkzvnhnki-zgw63z-GET]
module.api_gateway.aws_api_gateway_method_response.rest_api_get_method_response_200: Refreshing state... [id=agmr-czkzvnhnki-zgw63z-GET-200]
module.api_gateway.aws_api_gateway_integration.rest_api_get_method_integration: Refreshing state... [id=agi-czkzvnhnki-zgw63z-GET]
module.api_gateway.aws_api_gateway_integration_response.rest_api_get_method_integration_response_200: Refreshing state... [id=agir-czkzvnhnki-zgw63z-GET-200]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # module.api_gateway.aws_api_gateway_integration.rest_api_get_method_integration will be destroyed
  - resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
      - cache_key_parameters = [] -> null
      - cache_namespace      = "zgw63z" -> null
      - connection_type      = "INTERNET" -> null
      - http_method          = "GET" -> null
      - id                   = "agi-czkzvnhnki-zgw63z-GET" -> null
      - passthrough_behavior = "WHEN_NO_MATCH" -> null
      - request_parameters   = {} -> null
      - request_templates    = {
          - "application/json" = jsonencode(
                {
                  - statusCode = 200
                }
            )
        } -> null
      - resource_id          = "zgw63z" -> null
      - rest_api_id          = "czkzvnhnki" -> null
      - timeout_milliseconds = 29000 -> null
      - type                 = "MOCK" -> null
    }

  # module.api_gateway.aws_api_gateway_integration_response.rest_api_get_method_integration_response_200 will be destroyed
  - resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
      - http_method         = "GET" -> null
      - id                  = "agir-czkzvnhnki-zgw63z-GET-200" -> null
      - resource_id         = "zgw63z" -> null
      - response_parameters = {} -> null
      - response_templates  = {
          - "application/json" = jsonencode(
                {
                  - body = "Hello from the registrations API!"
                }
            )
        } -> null
      - rest_api_id         = "czkzvnhnki" -> null
      - status_code         = "200" -> null
    }

  # module.api_gateway.aws_api_gateway_method.rest_api_get_method will be destroyed
  - resource "aws_api_gateway_method" "rest_api_get_method" {
      - api_key_required     = false -> null
      - authorization        = "NONE" -> null
      - authorization_scopes = [] -> null
      - http_method          = "GET" -> null
      - id                   = "agm-czkzvnhnki-zgw63z-GET" -> null
      - request_models       = {} -> null
      - request_parameters   = {} -> null
      - resource_id          = "zgw63z" -> null
      - rest_api_id          = "czkzvnhnki" -> null
    }

  # module.api_gateway.aws_api_gateway_method_response.rest_api_get_method_response_200 will be destroyed
  - resource "aws_api_gateway_method_response" "rest_api_get_method_response_200" {
      - http_method         = "GET" -> null
      - id                  = "agmr-czkzvnhnki-zgw63z-GET-200" -> null
      - resource_id         = "zgw63z" -> null
      - response_models     = {} -> null
      - response_parameters = {} -> null
      - rest_api_id         = "czkzvnhnki" -> null
      - status_code         = "200" -> null
    }

  # module.api_gateway.aws_api_gateway_resource.rest_api_resource will be destroyed
  - resource "aws_api_gateway_resource" "rest_api_resource" {
      - id          = "zgw63z" -> null
      - parent_id   = "jfw52ohe8a" -> null
      - path        = "/registrations" -> null
      - path_part   = "registrations" -> null
      - rest_api_id = "czkzvnhnki" -> null
    }

  # module.api_gateway.aws_api_gateway_rest_api.rest_api will be destroyed
  - resource "aws_api_gateway_rest_api" "rest_api" {
      - api_key_source               = "HEADER" -> null
      - arn                          = "arn:aws:apigateway:us-east-1::/restapis/czkzvnhnki" -> null
      - binary_media_types           = [] -> null
      - created_date                 = "2023-05-24T19:14:19Z" -> null
      - disable_execute_api_endpoint = false -> null
      - execution_arn                = "arn:aws:execute-api:us-east-1:770646514888:czkzvnhnki" -> null
      - id                           = "czkzvnhnki" -> null
      - minimum_compression_size     = -1 -> null
      - name                         = "wall-street-career-api-gateway" -> null
      - root_resource_id             = "jfw52ohe8a" -> null
      - tags                         = {} -> null
      - tags_all                     = {} -> null

      - endpoint_configuration {
          - types            = [
              - "EDGE",
            ] -> null
          - vpc_endpoint_ids = [] -> null
        }
    }

Plan: 0 to add, 0 to change, 6 to destroy.
module.api_gateway.aws_api_gateway_integration_response.rest_api_get_method_integration_response_200: Destroying... [id=agir-czkzvnhnki-zgw63z-GET-200]
module.api_gateway.aws_api_gateway_integration_response.rest_api_get_method_integration_response_200: Destruction complete after 1s
module.api_gateway.aws_api_gateway_method_response.rest_api_get_method_response_200: Destroying... [id=agmr-czkzvnhnki-zgw63z-GET-200]
module.api_gateway.aws_api_gateway_integration.rest_api_get_method_integration: Destroying... [id=agi-czkzvnhnki-zgw63z-GET]
module.api_gateway.aws_api_gateway_method_response.rest_api_get_method_response_200: Destruction complete after 0s
module.api_gateway.aws_api_gateway_integration.rest_api_get_method_integration: Destruction complete after 0s
module.api_gateway.aws_api_gateway_method.rest_api_get_method: Destroying... [id=agm-czkzvnhnki-zgw63z-GET]
module.api_gateway.aws_api_gateway_method.rest_api_get_method: Destruction complete after 0s
module.api_gateway.aws_api_gateway_resource.rest_api_resource: Destroying... [id=zgw63z]
module.api_gateway.aws_api_gateway_resource.rest_api_resource: Destruction complete after 0s
module.api_gateway.aws_api_gateway_rest_api.rest_api: Destroying... [id=czkzvnhnki]
module.api_gateway.aws_api_gateway_rest_api.rest_api: Destruction complete after 0s

Destroy complete! Resources: 6 destroyed.
PS C:\project area\wall-street-career-aws>


# PS C:\project area\wall-street-career-aws\terraform\modules\lambda_function> npm init- y
# PS C:\project area\wall-street-career-aws\terraform\modules\lambda_function> npm install jwt-decode


# Outputs:

cognito_client_id = "5160k0ou0rdr4rf6d86r16t0mb"
cognito_user_pool_id = "us-east-1_XuvZQmBE8"
rest_api_url = "https://aaiiuxs4r8.execute-api.us-east-1.amazonaws.com/prod/registrations"
PS C:\project area\wall-street-career-aws>