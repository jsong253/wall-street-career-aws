output "api_name" {
    value=aws_api_gateway_rest_api.rest_api.name
}
output "api_id" {
    value=aws_api_gateway_rest_api.rest_api.id
}

output "rest_api_url-get-registrations" {
  value = "${aws_api_gateway_deployment.rest_api_deployment.invoke_url}${aws_api_gateway_stage.rest_api_stage.stage_name}${aws_api_gateway_resource.rest_api_get_resource.path}"
}

output "rest_api_url-create-registrations" {
  value = "${aws_api_gateway_deployment.rest_api_deployment.invoke_url}${aws_api_gateway_stage.rest_api_stage.stage_name}${aws_api_gateway_resource.rest_api_create_resource.path}"
}
