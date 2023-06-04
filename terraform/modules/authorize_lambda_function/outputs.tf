output "authorize_lambda_function_arn" {
  value = aws_lambda_function.authorize_lambda_function.invoke_arn
}
output "authorize_lambda_function_name" {
  value = aws_lambda_function.authorize_lambda_function.function_name
}
output "invocation_role_arn" {
  value = aws_iam_role.authorize_lambda_execution_role.arn
}

