### schema validation
https://engineering.statefarm.com/blog/schema-validations/
https://github.com/c0nfleis/terraform-examples
https://docs.aws.amazon.com/apigateway/latest/developerguide/models-mappings-models.html        // excelent


### jsonschema validator
https://registry.terraform.io/providers/xxxbobrxxx/jsonschema/latest/docs/data-sources/jsonschema_validator

### Error: Error creating API Gateway Model: BadRequestException: Model name must be alphanumeric: registration_model_validation
│
│   with module.api_gateway.aws_api_gateway_model.registration_model,
│   on terraform\modules\api_gateway\rest_api.tf line 16, in resource "aws_api_gateway_model" "registration_model":
│   16: resource "aws_api_gateway_model" "registration_model" {
remove underscore in the name field:
  name         = "feedbackmodelvalidation${var.env}"