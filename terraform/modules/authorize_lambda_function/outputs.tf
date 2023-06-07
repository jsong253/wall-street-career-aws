output "authorize_lambda_function_invoke_arn" {
  value = aws_lambda_function.authorize_lambda_function.invoke_arn
}
output "authorize_lambda_function_name" {
  value = aws_lambda_function.authorize_lambda_function.function_name
}
output "authorize_lambda_invocation_role_arn" {
  value = aws_iam_role.invocation_role.arn
}

