output "feedback_get_lambda_function_arn" {
  value = aws_lambda_function.feedback_get_lambda_function.invoke_arn
}
output "feedback_get_lambda_function_name" {
  value = aws_lambda_function.feedback_get_lambda_function.function_name
}