output "create_lambda_function_arn" {
  value = aws_lambda_function.create_lambda_function.invoke_arn
}
output "create_lambda_function_name" {
  value = aws_lambda_function.create_lambda_function.function_name
}