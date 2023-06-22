output "request_authorize_lambda_function_invoke_arn" {
  value = aws_lambda_function.request_authorize_lambda_function.invoke_arn
}
output "request_authorize_lambda_function_name" {
  value = aws_lambda_function.request_authorize_lambda_function.function_name
}
output "request_authorize_lambda_invocation_role_arn" {
  value = aws_iam_role.invocation_role_feedback.arn
}

